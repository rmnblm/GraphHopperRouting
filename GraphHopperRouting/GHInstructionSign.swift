/**
 Specifies the sign of an instruction to show e.g. for right turn etc.
 */
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
