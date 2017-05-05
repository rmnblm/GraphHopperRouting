import Foundation

/**
 The algorithm to calculate the route.
 */
public enum RouteAlgorithm {
    case dijkstrabi
    case dijkstra
    case astar
    case astarbi
    case alternativeRoute(maxPaths: Int , maxWeightFactor: Float, maxShareFactor: Float)
    case roundTrip(distance: Int, seed: Int)
}

extension RouteAlgorithm {
    public func asParams() -> [URLQueryItem] {
        switch self {
        case .dijkstrabi:
            return [URLQueryItem(name: "algorithm", value: "dijkstrabi")]
        case .dijkstra:
            return [URLQueryItem(name: "algorithm", value: "dijkstra")]
        case .astar:
            return [URLQueryItem(name: "algorithm", value: "astar")]
        case .astarbi:
            return [URLQueryItem(name: "algorithm", value: "astarbi")]
        case .alternativeRoute(let maxPaths, let maxWeightFactor, let maxShareFactor):
            return [
                URLQueryItem(name: "algorithm", value: "alternative_route"),
                URLQueryItem(name: "max_paths", value: String(maxPaths)),
                URLQueryItem(name: "max_weight_factor", value: String(maxWeightFactor)),
                URLQueryItem(name: "max_share_factor", value: String(maxShareFactor))
            ]
        case .roundTrip(let distance, let seed):
            return [
                URLQueryItem(name: "algorithm", value: "round_trip"),
                URLQueryItem(name: "distance", value: String(distance)),
                URLQueryItem(name: "seed", value: String(seed))
            ]
        }
    }
}
