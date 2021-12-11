import Foundation

public struct AdjacentPointsGenerator: Sequence {
    private let adjacentPoints: [Int]

    public init(_ index: Int, rows: Int, columns: Int) {
        var adjacentPoints: [Int] = [
            index - columns,
            index + columns,
        ]

        let (_, column) = index.quotientAndRemainder(dividingBy: columns)

        if column > 0 {
            adjacentPoints.append(contentsOf: [
                index - 1,
                index - columns - 1,
                index + columns - 1,
            ])
        }

        if column + 1 < columns {
            adjacentPoints.append(contentsOf: [
                index + 1,
                index - columns + 1,
                index + columns + 1,
            ])
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
