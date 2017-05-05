/**
 The weighting for which kind of 'best' route calculation is needed.
 */
public enum RouteWeighting: String {
    case fastest = "fastest"
    case shortest = "shortest"
    case shortFastest = "short_fastest"
    case curvature = "curvature"
}
