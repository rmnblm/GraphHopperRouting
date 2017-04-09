//
//  ViewController.swift
//  GraphHopperRoutingExample
//
//  Created by Roman Blum on 04.04.17.
//  Copyright © 2017 rmnblm. All rights reserved.
//

import UIKit
import GraphHopperRouting

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let accessToken = "GRAPHHOPPER_ACCESS_TOKEN"
        let routing = Routing(accessToken: accessToken)
        let points = [
            RoutePoint(latitude: 52.545669, longitude: 13.359375),
            RoutePoint(latitude: 52.543164, longitude: 13.399887)
        ]
        let options = RouteOptions(points)
        options.elevation = true
        _ = routing.calculate(options, completionHandler: { (paths, error) in
            paths?.forEach({
                $0.points.forEach({ print("\($0.latitude) \($0.longitude) \($0.altitude)") })
                print($0.time)
                print($0.distance)
                print($0.descend)
                print($0.ascend)
            })
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

