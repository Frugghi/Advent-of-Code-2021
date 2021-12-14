import Foundation

public struct Pair: Hashable {
    public let first: Character
    public let second: Character

    public init<S>(_ string: S) where S: StringProtocol {
        first = string[string.startIndex]
        second = string[string.index(after: string.startIndex)]
    }

    public init(_ first: Character, _ second: Character) {
        self.first = first
        self.second = second
    }

    public func pairsInserting(_ element: Character) -> (first: Pair, second: Pair) {
        (
            Pair(first, element),
            Pair(element, second)
        )
    }
}

public extension String {
    func pairs() -> AnySequence<Pair> {
        AnySequence(indices.dropLast().lazy.map { index in
            Pair(self[index], self[self.index(after: index)])
        })
    }
}
