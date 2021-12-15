import Foundation

public struct FlattenMatrixAdjacentPointsGenerator: Sequence {
    private let adjacentPoints: [Int]

    public init(_ index: Int, rows: Int, columns: Int, includeDiagonals: Bool = true) {
        let adjacentPoints = Array<Int>(unsafeUninitializedCapacity: 8) { buffer, initializedCount in
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
        }

        let matrixSize = rows * columns
        self.adjacentPoints = adjacentPoints.filter { index in
            index >= 0 && index < matrixSize
        }
    }

    public func makeIterator() -> IndexingIterator<Array<Int>> {
        adjacentPoints.makeIterator()
    }
}
