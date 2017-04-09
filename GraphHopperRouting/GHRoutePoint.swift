import CoreLocation

open class RoutePoint {
    public let latitude: CLLocationDegrees
    public let longitude: CLLocationDegrees
    public let altitude: CLLocationDistance

    public init(latitude: CLLocationDegrees, longitude: CLLocationDegrees, altitude: CLLocationDistance = 0.0) {
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
    }

    public convenience init(coordinate: CLLocationCoordinate2D) {
        self.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }

    public convenience init(location: CLLocation) {
        self.init(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, altitude: location.altitude)
    }

    public var location: CLLocation {
        return CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            altitude: altitude,
            horizontalAccuracy: 0,
            verticalAccuracy: 0,
            course: 0,
            speed: 0,
            timestamp: Date())
    }
}
