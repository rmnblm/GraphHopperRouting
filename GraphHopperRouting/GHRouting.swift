import Foundation

public typealias JSONDictionary = [String: Any]

let GHRoutingErrorDomain = "GHRoutingErrorDomain"
let defaultAccessToken = Bundle.main.object(forInfoDictionaryKey: "GraphHopperAccessToken") as? String

/**
 A `Routing` object is used to calculate one or more routes between given waypoints. The routing object passes your request to the [GraphHopper Routing API](https://graphhopper.com/api/1/docs/routing/) and asynchronously returns the requested information to a completion handler that you provide. 

 */
open class Routing: NSObject {

    /**
     A closure (block) to be called when a routing request is complete.

     - parameter paths: An array of possible paths
        If the request was canceled or there was an error obtaining the routes, this parameter may be `nil`.
     - parameter error: The error that occurred, or `nil` if the paths were obtained successfully.
     */
    public typealias CompletionHandler = (_ paths: [RoutePath]?, _ error: Error?) -> Void

    /**
     The shared routing object.
     
     If this object is used, the GraphHopper Access Token must be specified in the Info.plist of the application's main bundle with the key `GraphHopperAccessToken`.
     */
    public static let shared = Routing(accessToken: nil)

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

     - parameter options: A `RouteOptions` object specifying the options to consider when calling the GraphHopper Routing API.
     - parameter completionHandler: The closure (block) to call with the resulting paths.
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
            var json: JSONDictionary = [:]
            if let data = data, response?.mimeType == "application/json" {
                do {
                  json = try JSONSerialization.jsonObject(with: data, options: []) as! JSONDictionary
                } catch {
                  assert(false, "Unable to parse JSON.")
                }
            }

            let apiMessage = json["message"] as? String
            guard data != nil && error == nil && apiMessage == nil else {
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

internal extension HTTPURLResponse {
    var creditLimit: Int? {
        guard let limit = allHeaderFields["X-RateLimit-Limit"] as? String else {
            return nil
        }

        return Int(limit)
    }

    var remainingCredits: Int? {
        guard let credits = allHeaderFields["X-RateLimit-Remaining"] as? String else {
            return nil
        }

        return Int(credits)
    }

    var timeUntilReset: TimeInterval? {
        guard let interval = allHeaderFields["X-RateLimit-Reset"] as? String else {
            return nil
        }

        return TimeInterval(interval)
    }

    var creditCosts: Double? {
        guard let costs = allHeaderFields["X-RateLimit-Credits"] as? Double else {
            return nil
        }

        return Double(costs)
    }
}
