import CoreLocation

internal extension CLLocation {
    convenience init(latitude: CLLocationDegrees, longitude: CLLocationDegrees, altitude: CLLocationDegrees) {
        self.init(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                  altitude: altitude, horizontalAccuracy: 0, verticalAccuracy: 0, course: 0, speed: 0, timestamp: Date())
    }
}
