import Foundation

public struct AdjacentPointsGenerator<Index>: Sequence {
    public typealias Element = Point<Index>
    private let adjacentPoints: [Element]

    public init<C>(
        _ collection: C,
        around point: Point<C.Index>
    ) where C: BidirectionalCollection, C.Index == Index, C.Element: BidirectionalCollection, C.Element.Index == Index {
        var adjacentPoints: [Element] = []
        let x = point.x
        let y = point.y
        if x > collection[y].startIndex {
            adjacentPoints.append(Point(x: collection[y].index(before: x), y: y))
        }
        if collection[y].index(after: x) < collection[y].endIndex {
            adjacentPoints.append(Point(x: collection[y].index(after: x), y: y))
        }
        if y > collection.startIndex {
            adjacentPoints.append(Point(x: x, y: collection.index(before: y)))
        }
        if collection.index(after: y) < collection.endIndex {
            adjacentPoints.append(Point(x: x, y: collection.index(after: y)))
        }

        self.adjacentPoints = adjacentPoints
    }

    public func makeIterator() -> IndexingIterator<Array<Element>> {
        adjacentPoints.makeIterator()
    }
}
