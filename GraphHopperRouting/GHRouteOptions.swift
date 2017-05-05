import CoreLocation

open class RouteOptions: NSObject {
    public let points: [CLLocationCoordinate2D]
    public var locale: String?
    public var optimize: Bool?
    public var instructions: Bool?
    public var vehicle: VehicleType?
    public var elevation: Bool?
    public var encodePoints: Bool?
    public var calculatePoints: Bool?
    public var debug: Bool?

    public init(_ points: [CLLocationCoordinate2D]) {
        assert(points.count >= 2, "Specify at least two points.")
        self.points = points
    }

    internal var params: [URLQueryItem] {
        var params = [URLQueryItem]()

        let pointQueries = points.map({ URLQueryItem(name: "point", value: "\($0.latitude),\($0.longitude)") })
        params.append(contentsOf: pointQueries)
        params.append(URLQueryItem(name: "type", value: "application/json"))

        if let locale = self.locale {
            params.append(URLQueryItem(name: "locale", value: locale))
        }

        if let instructions = self.instructions {
            params.append(URLQueryItem(name: "instructions", value: String(instructions)))
        }

        if let encodePoints = self.encodePoints {
            params.append(URLQueryItem(name: "points_encoded", value: String(encodePoints)))
        }

        if let calculatePoints = self.calculatePoints {
            params.append(URLQueryItem(name: "calc_points", value: String(calculatePoints)))
        }

        if let optimize = self.optimize {
            params.append(URLQueryItem(name: "optimize", value: String(optimize)))
        }

        if let vehicle = self.vehicle {
            params.append(URLQueryItem(name: "vehicle", value: vehicle.rawValue))
        }

        if let debug = self.debug {
            params.append(URLQueryItem(name: "debug", value: String(debug)))
        }

        if let elevation = self.elevation {
            params.append(URLQueryItem(name: "elevation", value: String(elevation)))
        }

        return params
    }

    internal func response(_ json: JSONDictionary) -> ([RoutePath]?) {
        return (json["paths"] as? [JSONDictionary])?.flatMap({ jsonPath in
            return RoutePath(json: jsonPath, withOptions: self)
        })
    }
}

open class FlexibleRouteOptions: RouteOptions {
    public var weighting: RouteWeighting = .fastest
    public var algorithm: RouteAlgorithm = .astarbi

    public var passThrough: Bool?
    public var heading: [Double]?
    public var headingPenalty: Int?

    override var params: [URLQueryItem] {
        var params = super.params

        params.append(URLQueryItem(name: "ch.disable", value: "true"))
        params.append(URLQueryItem(name: "weighting", value: weighting.rawValue))
        params.append(contentsOf: algorithm.asParams())

        if let passThrough = self.passThrough {
            params.append(URLQueryItem(name: "pass_through", value: String(passThrough)))
        }

        if let heading = self.heading {
            params.append(URLQueryItem(name: "heading", value: heading.map({ String($0) }).joined(separator: ",")))
        }

        if let headingPenalty = self.headingPenalty {
            params.append(URLQueryItem(name: "heading_penalty", value: String(headingPenalty)))
        }

        return params
    }
}
