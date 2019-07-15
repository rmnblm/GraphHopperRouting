import CoreLocation

/**
 A `BoundingBox` object is an area defined by two coordinates, top-left and bottom-right.
 */
open class BoundingBox {
    public let topLeft: CLLocationCoordinate2D
    public let bottomRight: CLLocationCoordinate2D

    /**
     Initializes a new bounding box object with the two coordinates, top-left and bottom-right.

     - paramter northWest: The top-left coordinate of the bbox.
     - paramter southEast: The bottom-right coordinate of the bbox.
     */
    internal init(topLeft: CLLocationCoordinate2D, bottomRight: CLLocationCoordinate2D) {
        self.topLeft = topLeft
        self.bottomRight = bottomRight
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
            topLeft: CLLocationCoordinate2D(latitude: degrees[1], longitude: degrees[0]),
            bottomRight: CLLocationCoordinate2D(latitude: degrees[3], longitude: degrees[2])
        )
    }
}
