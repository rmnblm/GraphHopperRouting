import CoreLocation

open class Instruction {

    fileprivate let json: JSONDictionary

    init(json: JSONDictionary) {
        self.json = json
    }

    open lazy var text: String = {
        return self.json["text"] as? String ?? ""
    }()

    open lazy var streetName: String = {
        return self.json["street_name"] as? String ?? ""
    }()

    open lazy var distance: CLLocationDistance = {
        return self.json["distance"] as? CLLocationDistance ?? 0.0
    }()

    open lazy var time: Int = {
        return self.json["time"] as? Int ?? 0
    }()

    open lazy var interval: [Int] = {
        return self.json["interval"] as? [Int] ?? []
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
