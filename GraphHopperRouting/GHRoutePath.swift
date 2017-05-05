import CoreLocation

open class RoutePath {
    fileprivate let json: JSONDictionary
    fileprivate let elevation: Bool
    fileprivate let encoded: Bool

    internal init(_ json: JSONDictionary, elevation: Bool, encoded: Bool) {
        self.json = json
        self.elevation = elevation
        self.encoded = encoded
    }

    public convenience init?(json: JSONDictionary, withOptions options: RouteOptions) {
        self.init(json, elevation: options.elevation, encoded: options.encodePoints)
    }

    open lazy var instructions: [Instruction] = {
        return (self.json["instructions"] as? [JSONDictionary])?.flatMap({ Instruction(json: $0) }) ?? []
    }()

    open lazy var bbox: BoundingBox? = {
        guard let degrees = self.json["bbox"] as? [CLLocationDegrees] else {
            return nil
        }
        return BoundingBox(degrees: degrees)
    }()

    open lazy var points: [CLLocation] = {
        return self.processPoints(jsonKey: "points")
    }()

    open lazy var snappedWaypoints: [CLLocation] = {
        return self.processPoints(jsonKey: "snapped_waypoints")
    }()

    open lazy var time: Int = {
        return self.json["time"] as? Int ?? 0
    }()

    open lazy var distance: CLLocationDistance = {
        return self.json["distance"] as? CLLocationDistance ?? 0.0
    }()

    open lazy var ascend: CLLocationDistance = {
        return self.json["ascend"] as? CLLocationDistance ?? 0.0
    }()

    open lazy var descend: CLLocationDistance = {
        return self.json["descend"] as? CLLocationDistance ?? 0.0
    }()

    open lazy var pointsOrder: [Int] = {
        return self.json["points_order"] as? [Int] ?? []
    }()

    open lazy var transfers: Int = {
        return self.json["transfers"] as? Int ?? 0
    }()

    open lazy var weight: Double = {
        return self.json["weight"] as? Double ?? Double.infinity
    }()
}

extension RoutePath {
    fileprivate func processPoints(jsonKey: String) -> [CLLocation] {
        var points = [CLLocation]()
        if encoded {
            if let encodedPoints = json[jsonKey] as? String {
                points = Decoder.decodePoints(encodedPoints, is3D: elevation)
            }
        } else {
            if let geojson = json[jsonKey] as? JSONDictionary {
                if let coordinates = geojson["coordinates"] as? [[CLLocationDegrees]] {
                    points = coordinates.map({
                        return CLLocation(
                            latitude: $0.count >= 2 ? $0[1] : 0.0,
                            longitude: $0.count >= 1 ? $0[0] : 0.0,
                            altitude: $0.count >= 3 ? $0[2] : 0.0)
                    })
                }
            }
        }
        return points
    }
}
