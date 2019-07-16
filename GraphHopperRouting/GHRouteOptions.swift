import CoreLocation

/**
 A `RouteOptions` object is used to specify user-defined options when querying the GraphHopper Routing API.
 */
open class RouteOptions: NSObject {
    /**
     Specifiy multiple points for which the route should be calculated.
     */
    public let points: [CLLocationCoordinate2D]

    /** 
     If `true` the coordinates will be encoded as string leading to less bandwith usage.
     */
    public var encodePoints: Bool = true

    /**
     The locale of the resulting turn instructions. E.g. pt_PT for Portuguese or de for German.
     
     Uses the current language code by default.
     */
    public var locale: String? = Locale.current.languageCode

    /**
     If `false` the order of the locations will be identical to the order of the point parameters. If you have more than 2 points you can set this optimize parameter to true and the points will be sorted regarding the minimum overall time - e.g. suiteable for sightseeing tours or salesman.
     */
    public var optimize: Bool?

    /**
     If instructions should be calculated and returned
     */
    public var instructions: Bool?

    /**
     The vehicle for which the route should be calculated.
     */
    public var vehicle: VehicleType?

    /**
     If `true` a third dimension - the elevation - is included in the result. 
     
     IMPORTANT: If enabled you have set `encodePoints` to `false.
     */
    public var elevation: Bool?

    /**
     If the points for the route should be calculated at all printing out only distance and time.
     */
    public var calculatePoints: Bool?

    /**
     Initializes a route options object for routes between the given points.

     - parameter points: An array of `CLLocationCoordinate2D` objects representing coordinates that the route should visit in chronological order. The array must contain at least two coordinates (the source and destination).
     */
    public init(points: [CLLocationCoordinate2D]) {
        assert(points.count >= 2, "Specify at least two points.")
        self.points = points
    }

    internal var params: [URLQueryItem] {
        var params = [URLQueryItem]()

        let pointQueries = points.map({ URLQueryItem(name: "point", value: "\($0.latitude),\($0.longitude)") })
        params.append(contentsOf: pointQueries)
        params.append(URLQueryItem(name: "type", value: "application/json"))
        params.append(URLQueryItem(name: "points_encoded", value: String(encodePoints)))

        if let locale = self.locale {
            params.append(URLQueryItem(name: "locale", value: locale))
        }

        if let instructions = self.instructions {
            params.append(URLQueryItem(name: "instructions", value: String(instructions)))
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

        if let elevation = self.elevation {
            params.append(URLQueryItem(name: "elevation", value: String(elevation)))
        }

        return params
    }

    internal func response(_ json: JSONDictionary) -> ([RoutePath]?) {
        return (json["paths"] as? [JSONDictionary])?.compactMap({ jsonPath in
            return RoutePath(json: jsonPath, withOptions: self)
        })
    }
}

/**
 A `FlexibleRouteOptions` object is used to specify options with flexible features when querying the GraphHopper Routing API.
 */
open class FlexibleRouteOptions: RouteOptions {
    /**
     Which kind of 'best' route calculation you need.
    */
    public var weighting: RouteWeighting = .fastest

    /**
     The algorithm to calculate the route.
     */
    public var algorithm: RouteAlgorithm = .astarbi

    /**
     If true u-turns are avoided at via-points with regard to the `heading_penalty`.
     */
    public var passThrough: Bool?

    /**
     Favour a heading direction for a certain point. Specify either one heading for the start point or as many as there are points. In this case headings are associated by their order to the specific points. Headings are given as north based clockwise angle between 0 and 360 degree.
     */
    public var heading: [Double]?

    /** 
     Penalty for omitting a specified heading. The penalty corresponds to the accepted time delay in seconds in comparison to the route without a heading.
     */
    public var headingPenalty: Int?

    internal override var params: [URLQueryItem] {
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
