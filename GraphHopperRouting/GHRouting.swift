import Foundation

public typealias JSONDictionary = [String: Any]

let defaultAccessToken = Bundle.main.object(forInfoDictionaryKey: "GraphHopperAccessToken") as? String
let defaultApiVersion = "1"

enum NetworkError: Error {
    case InvalidRequest
    case Authentication
    case InvalidParameters
    case LimitExceeded
    case InternalServer
    case UnsupportedVehicles
    case Unknown
}

open class Routing: NSObject {

    public typealias CompletionHandler = (_ paths: [RoutePath]?, _ error: Error?) -> Void
    
    open static let shared = Routing(accessToken: nil)

    internal let accessToken: String
    internal let baseURL: URL

    public init(accessToken: String?, apiVersion: String? = nil) {
        guard let token = accessToken ?? defaultAccessToken else {
            fatalError("You must provide an access token in order to use the GraphHopper Routing API.")
        }

        self.accessToken = token

        var baseURLComponents = URLComponents()
        baseURLComponents.scheme = "https"
        baseURLComponents.host = "graphhopper.com"
        baseURLComponents.path = "/api/\(apiVersion ?? defaultApiVersion)/route"
        self.baseURL = baseURLComponents.url!
    }

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

    fileprivate func dataTask(
        withURL url: URL,
        completionHandler: @escaping (_ json: JSONDictionary) -> Void,
        errorHandler: @escaping (_ error: Error) -> Void) -> URLSessionDataTask {

        return URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    errorHandler(error)
                }
                return
            }

            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                assert(false, "Status code not available")
                return
            }

            if !(200...299 ~= statusCode) {
                DispatchQueue.main.async {
                    errorHandler(self.parseError(fromStatusCode: statusCode))
                }
                return
            }

            guard let data = data, response?.mimeType == "application/json" else {
                assert(false, "Invalid data")
                return
            }

            var json: JSONDictionary = [:]
            do {
                json = try JSONSerialization.jsonObject(with: data, options: []) as! JSONDictionary
            } catch {
                assert(false, "Invalid data")
            }

            DispatchQueue.main.async {
                completionHandler(json)
            }
        })
    }

    open func urlForCalculating(_ options: RouteOptions) -> URL {
        let params = options.params + [
            URLQueryItem(name: "key", value: accessToken),
        ]

        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!
        components.queryItems = params
        return components.url!
    }

    fileprivate func parseError(fromStatusCode code: Int) -> Error {
        switch code {
        case 400: return NetworkError.InvalidRequest
        case 401: return NetworkError.Authentication
        case 413: return NetworkError.InvalidParameters
        case 429: return NetworkError.LimitExceeded
        case 500: return NetworkError.InternalServer
        case 501: return NetworkError.UnsupportedVehicles
        default: return NetworkError.Unknown
        }
    }
}
