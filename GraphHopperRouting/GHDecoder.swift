import CoreLocation

internal func decodePoints(_ encoded: String, is3D: Bool = false) -> [RoutePoint] {
    var points = [RoutePoint]()
    let enc = encoded.unicodeScalars
    let len = enc.count
    var index = 0
    var lat: Double = 0, lng: Double = 0, alt: Double = 0

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

        let point = RoutePoint(latitude: lat / 1e5, longitude: lng / 1e5, altitude: alt / 100)
        points.append(point)
    }

    return points
}
