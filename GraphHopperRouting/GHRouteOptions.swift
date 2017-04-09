import CoreLocation

public enum RouteVehicleType: String {
    case car = "car"
    case motorcycle = "motorcycle"
    case smalltruck = "small_truck"
    case bus = "bus"
    case truck = "truck"
    case foot = "foot"
    case hike = "hike"
    case bike = "bike"
    case mountainbike = "mtb"
    case racingbike = "racing bike"
}

public enum RouteResultType: String {
    case json = "application/json"
    case gpx = "application/gpx+xml"
}

open class RouteOptions: NSObject {

    public let points: [RoutePoint]
    public var locale = "en"
    public var optimize = false
    public var instructions = true
    public var vehicle: RouteVehicleType = .car
    public var elevation = false
    public var encodePoints = true
    public var calculatePoints = true
    public var debug = false
    public var type: RouteResultType = .json

    public init(_ points: [RoutePoint]) {
        assert(points.count >= 2, "Specify at least two points.")
        self.points = points
    }

    internal var params: [URLQueryItem] {
        var params: [URLQueryItem] = [
            URLQueryItem(name: "locale", value: locale),
            URLQueryItem(name: "type", value: type.rawValue),
            URLQueryItem(name: "instructions", value: String(instructions)),
            URLQueryItem(name: "points_encoded", value: String(encodePoints)),
            URLQueryItem(name: "calc_points", value: String(calculatePoints)),
            URLQueryItem(name: "optimize", value: String(optimize)),
            URLQueryItem(name: "vehicle", value: vehicle.rawValue),
            URLQueryItem(name: "debug", value: String(debug)),
            URLQueryItem(name: "elevation", value: String(elevation))
        ]

        let pointQueries = points.map({ URLQueryItem(name: "point", value: "\($0.latitude),\($0.longitude)") })
        params.append(contentsOf: pointQueries)

        return params
    }

    internal func response(_ json: JSONDictionary) -> ([RoutePath]?) {
        return (json["paths"] as? [JSONDictionary])?.flatMap({ jsonPath in
            return RoutePath(json: jsonPath, withOptions: self)
        })
    }
}
