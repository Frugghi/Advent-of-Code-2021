import Foundation

public enum CaveType {
    case big
    case small
    case start
    case end
}

public final class Cave: Hashable {
    public let name: String
    public let type: CaveType
    public private(set) var connectedCaves: Set<Cave> = []

    public init<S>(_ name: S) where S: StringProtocol {
        self.name = String(name)
        if name == "start" {
            type = .start
        } else if name == "end" {
            type = .end
        } else if name.allSatisfy(\.isUppercase) {
            type = .big
        } else {
            type = .small
        }
    }

    public func addConnectedCave(_ cave: Cave) {
        connectedCaves.insert(cave)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }

    public static func == (lhs: Cave, rhs: Cave) -> Bool {
        lhs.name == rhs.name
    }
}
