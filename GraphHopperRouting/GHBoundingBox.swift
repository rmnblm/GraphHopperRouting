import CoreLocation

/**
 A `BoundingBox` object is an area defined by two coordinates, north-west and south-east.
 */
open class BoundingBox {
    open let northWest: CLLocationCoordinate2D
    open let southEast: CLLocationCoordinate2D

    /**
     Initializes a new bounding box object with the two coordinates, north-west and south-east.

     - paramter northWest: The north-west coordinate of the bbox.
     - paramter southEast: The south-east coordinate of the bbox.
     */
    internal init(northWest: CLLocationCoordinate2D, southEast: CLLocationCoordinate2D) {
        self.northWest = northWest
        self.southEast = southEast
    }

    /**
     Initializes a new bounding box object.
     
     - paramter degrees: A array containing excactly four values of type `CLLocationDegrees` in the order `[minLongitude, minLatitude, maxLongitude, maxLatitude]`
     */
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
