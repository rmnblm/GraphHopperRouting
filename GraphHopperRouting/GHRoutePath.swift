import CoreLocation

open class RoutePath {

    open let points: [RoutePoint]
    open let distance: CLLocationDistance // in meter
    open let time: Int // in ms
    open let ascend: CLLocationDistance // in meter
    open let descend: CLLocationDistance // in meter

    internal init(_ points: [RoutePoint], distance: CLLocationDistance, time: Int, ascend: CLLocationDistance, descend: CLLocationDistance) {
        self.points = points
        self.time = time
        self.distance = distance
        self.ascend = ascend
        self.descend = descend
    }

    public convenience init?(json: JSONDictionary, withOptions options: RouteOptions) {
        var points = [RoutePoint]()
        if options.encodePoints {
            if let encoded = json["points"] as? String {
                points = decodePoints(encoded, is3D: options.elevation)
            }
        } else {
            if let geojson = json["points"] as? JSONDictionary {
                if let coordinates = geojson["coordinates"] as? [[Double]] {
                    points = coordinates.map({
                        return RoutePoint(
                            latitude: $0.count >= 2 ? $0[1] : 0.0,
                            longitude: $0.count >= 1 ? $0[0] : 0.0,
                            altitude: $0.count >= 3 ? $0[2] : 0.0)
                    })
                }
            }
        }

        let time = json["time"] as? Int ?? 0
        let distance = json["distance"] as? CLLocationDistance ?? 0.0
        let ascend = json["ascend"] as? CLLocationDistance ?? 0.0
        let descend = json["descend"] as? CLLocationDistance ?? 0.0
        self.init(points, distance: distance, time: time, ascend: ascend, descend: descend)
    }
}
