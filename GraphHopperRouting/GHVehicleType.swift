/** 
 The vehicle for which the route should be calculated.
 */
public enum VehicleType: String {
    /**
     Car mode
     */
    case car = "car"

    /** 
     Motor bike avoiding motorways
     */
    case motorcycle = "motorcycle"

    /**
     Small truck like a Mercedes Sprinter, Ford Transit or Iveco Daily
     */
    case smalltruck = "small_truck"

    /** 
     Bus where as public transport marked ways are allowed (psv ways and lanes)
     */
    case bus = "bus"

    /** 
     Truck like a MAN or Mercedes-Benz Actros
     */
    case truck = "truck"

    /**
     Pedestrian or walking
     */
    case foot = "foot"

    /**
     Pedestrian or walking with priority for more beautiful hiking tours and potentially a bit longer than foot
     */
    case hike = "hike"

    /**
     Trekking bike avoiding hills
     */
    case bike = "bike"

    /**
     Mountainbike
     */
    case mountainbike = "mtb"

    /**
     Bike preferring roads
     */
    case racingbike = "racing bike"
}
