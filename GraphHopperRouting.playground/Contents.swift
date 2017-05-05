import GraphHopperRouting
import CoreLocation
import PlaygroundSupport

let accessToken = "GRAPHHOPPER_ACCESS_TOKEN"
let routing = Routing(accessToken: accessToken)
let points = [
    CLLocationCoordinate2D(latitude: 52.545669, longitude: 13.359375),
    CLLocationCoordinate2D(latitude: 52.543164, longitude: 13.399887)
]
let options = RouteOptions(points)
options.elevation = true
_ = routing.calculate(options, completionHandler: { (paths, error) in
    paths?.forEach({
        $0.points.forEach({ print("\($0.coordinate.latitude) \($0.coordinate.longitude) \($0.altitude)") })
        print($0.time)
        print($0.distance)
        print($0.descend)
        print($0.ascend)
    })
})

PlaygroundPage.current.needsIndefiniteExecution = true
