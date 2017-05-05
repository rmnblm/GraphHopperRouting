import Foundation

public typealias JSONDictionary = [String: Any]

let GHRoutingErrorDomain = "GHRoutingErrorDomain"
let defaultAccessToken = Bundle.main.object(forInfoDictionaryKey: "GraphHopperAccessToken") as? String

/**

 */
open class Routing: NSObject {

    /**
     A closure (block) to be called when a directions request is complete.

     - parameter paths: An array of possible paths
        If the request was canceled or there was an error obtaining the routes, this parameter may be `nil`.
     - parameter error: The error that occurred, or `nil` if the paths were obtained successfully.
     */
    public typealias CompletionHandler = (_ paths: [RoutePath]?, _ error: Error?) -> Void

    /**
     The shared routing object.
     
     If this object is used, the GraphHopper Access Token must be specified in the Info.plist of the application's main bundle with the key `GraphHopperAccessToken`.
     */
    open static let shared = Routing(accessToken: nil)

    internal let accessToken: String
    internal let baseURL: URL

    /**
     Initializes a new routing object with an optional access token.
     
     - parameter accessToken: A GraphHopper Access Token. If nil, the access token must be specified in the Info.plist of the application's main bundle with the key `GraphHopperAccessToken`.
     */
    public init(accessToken: String?) {
        guard let token = accessToken ?? defaultAccessToken else {
            fatalError("You must provide an access token in order to use the GraphHopper Routing API.")
        }

        self.accessToken = token

        var baseURLComponents = URLComponents()
        baseURLComponents.scheme = "https"
        baseURLComponents.host = "graphhopper.com"
        baseURLComponents.path = "/api/1/route"
        self.baseURL = baseURLComponents.url!
    }

    /**
     Starts an asynchronous session task to calculate the route(s) and delivers the paths in the completion handler.
     
     - parameter options: A `RouteOptions` object specifying 
     */
    open func calculate(_ options: RouteOptions, completionHandler: @escaping CompletionHandler) -> URLSessionDataTask {
        let url = urlForCalculating(options)
        let task = dataTask(withURL: url, completionHandler: { (json) in
            let response = options.response(json)
            completionHandler(response, nil)
        }) { (error) in
            completionHandler(nil, error)
        }
        task.resume()
        return task
    }

    private func dataTask(
        withURL url: URL,
        completionHandler: @escaping (_ json: JSONDictionary) -> Void,
        errorHandler: @escaping (_ error: Error) -> Void) -> URLSessionDataTask {

        return URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            guard let data = data, response?.mimeType == "application/json" else {
                assert(false, "Invalid data.")
                return
            }

            var json: JSONDictionary = [:]

            do {
                json = try JSONSerialization.jsonObject(with: data, options: []) as! JSONDictionary
            } catch {
                assert(false, "Unable to parse JSON.")
            }

            let apiMessage = json["message"] as? String
            guard error == nil && apiMessage == nil else {
                let apiError = Routing.descriptiveError(json, response: response, underlyingerror: error as NSError?)
                DispatchQueue.main.async {
                    errorHandler(apiError)
                }
                return
            }

            DispatchQueue.main.async {
                completionHandler(json)
            }
        })
    }

    private func urlForCalculating(_ options: RouteOptions) -> URL {
        let params = options.params + [
            URLQueryItem(name: "key", value: accessToken),
        ]

        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!
        components.queryItems = params
        return components.url!
    }

    static func descriptiveError(_ json: JSONDictionary, response: URLResponse?, underlyingerror error: NSError?) -> NSError {
        var userInfo = error?.userInfo ?? [:]
        if let response = response as? HTTPURLResponse {
            var failureReason: String? = nil
            var recoverySuggestion: String? = nil

            switch response.statusCode {
            case 429:
                if let creditLimit = response.creditLimit {
                    let formattedCount = NumberFormatter.localizedString(from: creditLimit as NSNumber, number: .decimal)
                    failureReason = "More than \(formattedCount) requests have been made with this access token."
                }
                if let timeUntilReset = response.timeUntilReset {
                    let intervalFormatter = DateComponentsFormatter()
                    intervalFormatter.unitsStyle = .full
                    let formattedSeconds = intervalFormatter.string(from: timeUntilReset) ?? "\(timeUntilReset) seconds"
                    recoverySuggestion = "Wait \(formattedSeconds) before retrying."
                }
            default:
                failureReason = json["message"] as? String
            }
            userInfo[NSLocalizedFailureReasonErrorKey] = failureReason ?? userInfo[NSLocalizedFailureReasonErrorKey] ?? HTTPURLResponse.localizedString(forStatusCode: error?.code ?? -1)
            userInfo[NSLocalizedRecoverySuggestionErrorKey] = recoverySuggestion ?? userInfo[NSLocalizedRecoverySuggestionErrorKey]
        }

        if let error = error {
            userInfo[NSUnderlyingErrorKey] = error
        }

        return NSError(domain: error?.domain ?? GHRoutingErrorDomain, code: error?.code ?? -1, userInfo: userInfo)
    }
}

extension HTTPURLResponse {
    var creditLimit: Int? {
        return allHeaderFields["X-RateLimit-Limit"] as? Int
    }

    var remainingCredits: Int? {
        return allHeaderFields["X-RateLimit-Remaining"] as? Int
    }

    var timeUntilReset: TimeInterval? {
        return allHeaderFields["X-RateLimit-Reset"] as? TimeInterval
    }

    var creditCosts: Double? {
        return allHeaderFields["X-RateLimit-Credits"] as? Double
    }
}
