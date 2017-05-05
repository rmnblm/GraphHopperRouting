import CoreLocation

public enum InstructionSign: Int {
    case turnSharpLeft = -3
    case turnLeft = -2
    case turnSlightLeft = -1
    case continueOnStreet = 0
    case turnSlightRight = 1
    case turnRight = 2
    case turnSharpRight = 3
    case finish = 4
    case viaReached = 5
    case useRoundabout = 6
}

open class Instruction {

    fileprivate let json: JSONDictionary

    init(json: JSONDictionary) {
        self.json = json
    }

    open lazy var text: String? = {
        return self.json["text"] as? String
    }()

    open lazy var streetName: String? = {
        return self.json["street_name"] as? String
    }()

    open lazy var distance: CLLocationDistance? = {
        return self.json["distance"] as? CLLocationDistance
    }()

    open lazy var time: Int? = {
        return self.json["time"] as? Int
    }()

    open lazy var interval: [Int]? = {
        return self.json["interval"] as? [Int]
    }()

    open lazy var sign: InstructionSign? = {
        return self.json["sign"] as? InstructionSign
    }()

    open lazy var exitNumber: Int? = {
        return self.json["exit_number"] as? Int
    }()

    open lazy var turnAngle: Double? = {
        return self.json["turn_angle"] as? Double
    }()
}
