import Foundation

public struct Matrix2D<Element>: BidirectionalCollection {
    public typealias Index = Array<Element>.Index

    public var startIndex: Index { elements.startIndex }
    public var endIndex: Index { elements.endIndex }

    public let rows: Int
    public let columns: Int

    private var elements: [Element] = []

    public init(repeating repeatingElement: Element, rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns
        self.elements = Array(repeating: repeatingElement, count: rows * columns)
    }

    public init<S: Sequence>(_ sequence: S) where S.Element == [Element] {
        var elements: [Element] = []
        var rows = 0
        var columns = 0

        for row in sequence {
            assert(!row.isEmpty)

            rows += 1
            if columns == 0 {
                columns = row.count
            } else {
                assert(columns == row.count)
            }
            elements.append(contentsOf: row)
        }

        self.rows = rows
        self.columns = columns
        self.elements = elements
    }

    public func index(before i: Index) -> Index {
        elements.index(before: i)
    }

    public func index(after i: Index) -> Index {
        elements.index(after: i)
    }

    public subscript(position: Index) -> Element {
        get { elements[position] }
        set { elements[position] = newValue }
    }

    public func adjacentIndices(to index: Index, includeDiagonals: Bool = true) -> [Index] {
        Array<Index>(unsafeUninitializedCapacity: 8) { buffer, initializedCount in
            buffer[0] = index &- columns
            buffer[1] = index &+ columns
            initializedCount = 2

            let (column, _) = index.remainderReportingOverflow(dividingBy: columns)

            if column > 0 {
                buffer[initializedCount] = index &- 1
                initializedCount &+= 1

                if includeDiagonals {
                    buffer[initializedCount] = index &- columns &- 1
                    buffer[initializedCount &+ 1] = index &+ columns &- 1
                    initializedCount &+= 2
                }
            }

            if column &+ 1 < columns {
                buffer[initializedCount] = index &+ 1
                initializedCount &+= 1

                if includeDiagonals {
                    buffer[initializedCount] = index &- columns &+ 1
                    buffer[initializedCount &+ 1] = index &+ columns &+ 1
                    initializedCount &+= 2
                }
            }
        }.filter { $0 >= startIndex && $0 < endIndex }
    }
}
