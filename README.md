# GraphHopperRouting

🗺 The GraphHopper Routing API wrapped in an easy-to-use Swift framework.

The Routing API is part of the [GraphHopper Directions API](https://graphhopper.com/#directions-api). Routing is the process of finding the 'best' path(s) between two or more points, where best depends on the vehicle and use case. With our API you have a fast and solid way to find this best path.

## Installation

Use [CocoaPods](http://cocoapods.org/) to install the framework. Add this to your Podfile:

``` ruby
pod 'GraphHopperRouting'
```

Then run the following command:

``` 
$ pod install
```

In order to use the framework, you'll also need a [GraphHopper Access Token](https://graphhopper.com/dashboard/#/api-keys). You can either set your access token in the `Info.plist` (Key is GraphHopperAccessToken) or pass it as an argument to the initializer of the `Routing` class.

## Example

### Basics

Setup the `Routing` class

``` swift
import GraphHopperRouting

// use this
let routing = Routing(accessToken: "YOUR ACCESS TOKEN")
// or if you have set your access token in the Info.plist
let routing = Routing()
```

### Route options

Specify multiple points for which the route should be calculated.

```swift
let points = [
    CLLocationCoordinate2D(latitude: 52.545669, longitude: 13.359375),
    CLLocationCoordinate2D(latitude: 52.543164, longitude: 13.399887)
]
```

Configure the route options 

``` swift
let options = RouteOptions(points)
options.elevation = true
```

### Flexible route options

Flexible route options are used to specify flexible features when querying the GraphHopper Routing API.

```swift
let options = FlexibleRouteOptions()
options.weighting = .shortest
options.algorithm = .dijkstrabi
```

### Routing request

Make the async request by calling the `calculate(_:completionHandler)` method and passing the options.

```swift
let task = routing.calculate(options, completionHandler: { (paths, error) in
    paths?.forEach({ path in
        print(path.time)
        print(path.distance)
        print(path.descend)
        print(path.ascend)
        path.points.forEach({ point in
        	print(point)
        })
    })
})
```

## More information

For more information, consider the [official documentation](https://graphhopper.com/api/1/docs/routing/) to learn more about the options and the result.

## License

This project is released under the [MIT license](LICENSE).

## About

<img src="images/HSRLogo.png" width="184" />

​The GraphHopper Geocoder Swift Framework is crafted with ​:heart:​ by [@rmnblm](https://github.com/rmnblm) and [@iphilgood](https://github.com/iphilgood) during the Bachelor thesis at [HSR University of Applied Sciences](https://www.hsr.ch) in Rapperswil.
