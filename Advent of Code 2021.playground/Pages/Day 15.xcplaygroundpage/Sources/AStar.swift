import Foundation

public struct AStar {
    private let matrix: Matrix2D<UInt8>
    private let startIndex: Int
    private let endIndex: Int
    private let heuristic: (Int) -> UInt

    private(set) var minHeap: Heap<(index: Int, cost: UInt)>
    private(set) var costs: [UInt]

    public init(from startIndex: Int, to endIndex: Int, in matrix: Matrix2D<UInt8>) {
        self.startIndex = startIndex
        self.endIndex = endIndex
        self.matrix = matrix

        minHeap = Heap<(index: Int, cost: UInt)> { $0.cost < $1.cost }
        costs = Array(repeating: UInt.max, count: matrix.count)

        let (targetRow, targetColumn) = endIndex.quotientAndRemainder(dividingBy: matrix.columns)
        heuristic = { index in
            let (row, column) = index.quotientAndRemainder(dividingBy: matrix.columns)

            return numericCast(abs(targetRow &- row) &+ abs(targetColumn &- column))
        }

        minHeap.insert((index: startIndex, cost: heuristic(startIndex)))
        costs[startIndex] = 0
    }

    public func search() -> UInt {
        var search = self
        var step: (index: Int, cost: UInt)?
        repeat {
            step = search.nextStep()
        } while step != nil && step?.index != search.endIndex

        return search.costs[endIndex]
    }

    public func bidirectionalSearch() -> UInt {
        var forward = self
        var backward = AStar(from: endIndex, to: startIndex, in: matrix)

        var forwardStep = forward.nextStep()
        var backwardStep = backward.nextStep()
        while let (forwardIndex, forwardCost) = forwardStep,
              let (backwardIndex, backwardCost) = backwardStep,
              forward.costs[backwardIndex] == .max && backward.costs[forwardIndex] == .max {
            if forwardCost < backwardCost {
                forwardStep = forward.nextStep()
            } else {
                backwardStep = backward.nextStep()
            }
        }

        if backwardStep == nil {
            return backward.costs[startIndex]
        } else if forwardStep == nil {
            return forward.costs[endIndex]
        } else {
            let index = forward.costs[backwardStep!.index] != .max ? backwardStep!.index : forwardStep!.index
            return forward.costs[index] + backward.costs[index]
                    + numericCast(matrix[endIndex]) // Add the cost of the final step to the backward search
                    - numericCast(matrix[index])    // The current step has been counted twice
        }
    }

    mutating func nextStep() -> (index: Int, cost: UInt)? {
        guard let current = minHeap.pop() else { return nil }

        for index in matrix.adjacentIndices(to: current.index, includeDiagonals: false) {
            let cost = costs[current.index] &+ numericCast(matrix[index])
            if cost < costs[index] {
                costs[index] = cost
                
                let element = (index: index, cost: cost &+ heuristic(index))
                minHeap.insert(element)
            }
        }

        return current
    }
}
