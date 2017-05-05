import CoreLocation

/**
 An `Instruction` object contains all necessary information to explain how to perform a certain part of a `RoutePath`.
 */
open class Instruction {

    fileprivate let json: JSONDictionary

    /** 
     Initializes a new instruction object with the given JSON dictionary representation.
     */
    public init(json: JSONDictionary) {
        self.json = json
    }

    /** 
     A description what the user has to do in order to follow the route. The language depends on the locale parameter.
     */
    open lazy var text: String = {
        return self.json["text"] as? String ?? ""
    }()

    /**
     The name of the street the instruction takes place.
     */
    open lazy var streetName: String = {
        return self.json["street_name"] as? String ?? ""
    }()

    /**
     The distance for this instruction, in meter
     */
    open lazy var distance: CLLocationDistance = {
        return self.json["distance"] as? CLLocationDistance ?? 0.0
    }()

    /**
     The duration for this instruction, in ms
     */
    open lazy var time: Int = {
        return self.json["time"] as? Int ?? 0
    }()

    /**
     An array containing the first and the last index (relative to paths[0].points) of the points for this instruction. This is useful to know for which part of the route the instructions are valid.
     */
    open lazy var interval: [Int] = {
        return self.json["interval"] as? [Int] ?? []
    }()

    /**
     An enum which specifies the sign to show e.g. for right turn etc.
     */
    open lazy var sign: InstructionSign? = {
        return self.json["sign"] as? InstructionSign
    }()

    /**
     Only available when `sign` is `useRoundabout`. The count of exits at which the route leaves the roundabout.
     */
    open lazy var exitNumber: Int? = {
        return self.json["exit_number"] as? Int
    }()

    /**
     Only available when `sign` is `useRoundabout`. The radian of the route within the roundabout: 0<r<2*PI for clockwise and -2PI<r<0 for counterclockwise transit. If null the direction of rotation is undefined.
     */
    open lazy var turnAngle: Double? = {
        return self.json["turn_angle"] as? Double
    }()
}
