import Foundation

public protocol ExplorationStrategy: AnyObject {
    func explore(_ cave: Cave, exploration: (ExplorationStrategy) -> Void)
}

public extension ExplorationStrategy {
    func exploreCaves(from cave: Cave) -> Int {
        guard cave.type != .end else { return 1 }
        var count = 0

        for cave in cave.connectedCaves {
            explore(cave) { strategy in
                count += strategy.exploreCaves(from: cave)
            }
        }

        return count
    }
}

public class PartOneExplorationStrategy: ExplorationStrategy {
    private var exploredCaves: Set<Cave> = []

    public init() {}

    public func explore(_ cave: Cave, exploration: (ExplorationStrategy) -> Void) {
        guard cave.type != .start else { return }
        guard cave.type == .big || !exploredCaves.contains(cave) else { return }
        exploredCaves.insert(cave)
        defer { exploredCaves.remove(cave) }
        exploration(self)
    }
}

public class PartTwoExplorationStrategy: ExplorationStrategy {
    private var exploredCaves: Set<Cave> = []
    private var smallCaveExploredTwice: Bool = false

    public init() {}

    public func explore(_ cave: Cave, exploration: (ExplorationStrategy) -> Void) {
        guard cave.type != .start else { return }
        guard cave.type == .big || !smallCaveExploredTwice || !exploredCaves.contains(cave) else { return }
        let (inserted, _) = exploredCaves.insert(cave)
        if !inserted && cave.type == .small {
            smallCaveExploredTwice = true
        }
        defer {
            if inserted {
                exploredCaves.remove(cave)
            } else if cave.type == .small {
                smallCaveExploredTwice = false
            }
        }
        exploration(self)
    }
}
