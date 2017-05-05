import CoreLocation

internal final class Decoder {
    /**
     Special handling for the decoding of the encoded points string.
     
     - paramter encoded: The encoded string of points.
     - paramter is3D: Specifies if the points in the encoded string also contains elevation.
     */
    class func decodePoints(_ encoded: String, is3D: Bool = false) -> [CLLocation] {
        var points = [CLLocation]()
        let enc = encoded.unicodeScalars
        let len = enc.count
        var index = 0
        var lat: CLLocationDegrees = 0, lng: CLLocationDegrees = 0, alt: CLLocationDegrees = 0

        while (index < len) {
            // latitude
            var b = 0, shift = 0, result = 0
            repeat {
                let subscriptIndex = enc.index(enc.startIndex, offsetBy: index)
                let char = enc[subscriptIndex]
                b = Int(char.value) - 63
                result |= (b & 0x1f) << shift
                shift += 5
                index = index + 1
            } while(b >= 0x20)
            let deltaLatitude = Double(((result & 1) != 0 ? ~(result >> 1) : (result >> 1)))
            lat = lat + deltaLatitude

            // longitude
            shift = 0
            result = 0
            repeat {
                let subscriptIndex = enc.index(enc.startIndex, offsetBy: index)
                let char = enc[subscriptIndex]
                b = Int(char.value) - 63
                result |= (b & 0x1f) << shift
                shift += 5
                index = index + 1
            } while(b >= 0x20)
            let deltaLongitude = Double(((result & 1) != 0 ? ~(result >> 1) : (result >> 1)))
            lng = lng + deltaLongitude

            if is3D {
                // altitude
                shift = 0
                result = 0
                repeat {
                    let subscriptIndex = enc.index(enc.startIndex, offsetBy: index)
                    let char = enc[subscriptIndex]
                    b = Int(char.value) - 63
                    result |= (b & 0x1f) << shift
                    shift += 5
                    index = index + 1
                } while(b >= 0x20)
                let deltaAltitude = Double(((result & 1) != 0 ? ~(result >> 1) : (result >> 1)))
                alt = alt + deltaAltitude
                
            }
            
            let point = CLLocation(latitude: lat / 1e5, longitude: lng / 1e5, altitude: alt / 100)
            points.append(point)
        }
        
        return points
    }
}
