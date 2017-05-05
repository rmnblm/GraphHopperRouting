import CoreLocation

open class BoundingBox {
    open let northWest: CLLocationCoordinate2D
    open let southEast: CLLocationCoordinate2D

    init(northWest: CLLocationCoordinate2D, southEast: CLLocationCoordinate2D) {
        self.northWest = northWest
        self.southEast = southEast
    }

    public convenience init?(degrees: [CLLocationDegrees]) {
        guard degrees.count == 4 else {
            return nil
        }

        self.init(
            northWest: CLLocationCoordinate2D(latitude: degrees[1], longitude: degrees[0]),
            southEast: CLLocationCoordinate2D(latitude: degrees[3], longitude: degrees[2])
        )
    }
}
