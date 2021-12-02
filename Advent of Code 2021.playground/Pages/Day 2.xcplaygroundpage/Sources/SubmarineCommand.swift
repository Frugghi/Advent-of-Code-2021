import Foundation

public enum SubmarineCommand: LosslessStringConvertible {
    case forward(Int)
    case down(Int)
    case up(Int)

    public var description: String {
        switch self {
        case .forward(let value): return "forward \(value)"
        case .down(let value): return "down \(value)"
        case .up(let value): return "up \(value)"
        }
    }

    public init?(_ description: String) {
        let components = description.split(separator: " ", omittingEmptySubsequences: true)
        guard components.count == 2, let value = Int(components[1]) else { return nil }

        switch components[0] {
        case "forward": self = .forward(value)
        case "down": self = .down(value)
        case "up": self = .up(value)
        default: return nil
        }
    }
}
