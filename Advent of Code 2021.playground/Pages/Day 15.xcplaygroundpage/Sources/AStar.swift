import Foundation

public struct AStar {
    private typealias AdjacentPointsGenerator = FlattenMatrixAdjacentPointsGenerator
    private let rows: Int
    private let columns: Int
    private let flattenMatrix: [UInt8]
    private let startIndex: Int
    private let endIndex: Int
    private let heuristic: (Int) -> UInt

    private(set) var minHeap: Heap<(index: Int, cost: UInt)>
    private(set) var costs: [UInt]
    private var heapSet: Set<Int>

    public init(from startIndex: Int, to endIndex: Int, in flattenMatrix: [UInt8], rows: Int, columns: Int) {
        self.startIndex = startIndex
        self.endIndex = endIndex
        self.flattenMatrix = flattenMatrix
        self.rows = rows
        self.columns = columns

        minHeap = Heap<(index: Int, cost: UInt)> { $0.cost < $1.cost }
        costs = Array(repeating: UInt.max, count: flattenMatrix.count)
        heapSet = []

        let (targetRow, targetColumn) = endIndex.quotientAndRemainder(dividingBy: columns)
        heuristic = { index in
            let (row, column) = index.quotientAndRemainder(dividingBy: columns)

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
        var backward = AStar(from: endIndex, to: startIndex, in: flattenMatrix, rows: rows, columns: columns)

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
                    + numericCast(flattenMatrix[endIndex]) // Add the cost of the final step to the backward search
                    - numericCast(flattenMatrix[index])    // The current step has been counted twice
        }
    }

    mutating func nextStep() -> (index: Int, cost: UInt)? {
        guard let current = minHeap.pop() else { return nil }
        heapSet.remove(current.index)

        for index in AdjacentPointsGenerator(current.index, rows: rows, columns: columns, includeDiagonals: false) {
            let cost = costs[current.index] &+ numericCast(flattenMatrix[index])
            if cost < costs[index] {
                costs[index] = cost
                let element = (index: index, cost: cost &+ heuristic(index))

                if heapSet.insert(element.index).inserted {
                    minHeap.insert(element)
                } else {
                    minHeap.replace(with: element) { $0.index == element.index }
                }
            }
        }

        return current
    }
}

public func biastar(from startIndex: Int, to endIndex: Int, in flattenMatrix: [UInt8], rows: Int, columns: Int) -> UInt {
    var forward = AStar(from: startIndex, to: endIndex, in: flattenMatrix, rows: rows, columns: columns)
    var backward = AStar(from: endIndex, to: startIndex, in: flattenMatrix, rows: rows, columns: columns)

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
                + numericCast(flattenMatrix[endIndex]) // Add the cost of the final step to the backward search
                - numericCast(flattenMatrix[index])    // The current step has been counted twice
    }

//    var forwardStep = forward.nextStep()!
//    var backwardStep = backward.nextStep()!
//    repeat {
//        if forwardStep.cost < backwardStep.cost {
//            forwardStep = forward.nextStep()!
//        } else {
//            backwardStep = backward.nextStep()!
//        }
//
//        if forward.costs[backwardStep.index] != .max {
//            let index = backwardStep.index
//            return forward.costs[index] + backward.costs[index] - numericCast(flattenMatrix[index]) + numericCast(flattenMatrix[endIndex])
//        } else if backward.costs[forwardStep.index] != .max {
//            let index = forwardStep.index
//            return forward.costs[index] + backward.costs[index] - numericCast(flattenMatrix[index]) + numericCast(flattenMatrix[endIndex])
//        }
//    } while true
}

public func astar(from startIndex: Int, to endIndex: Int, in flattenMatrix: [UInt8], rows: Int, columns: Int) -> UInt {
    typealias AdjacentPointsGenerator = FlattenMatrixAdjacentPointsGenerator

    let heuristic = { (index: Int) -> UInt in
        let (targetRow, targetColumn) = endIndex.quotientAndRemainder(dividingBy: columns)
        let (row, column) = index.quotientAndRemainder(dividingBy: columns)

        return UInt(abs(targetRow - row)) + UInt(abs(targetColumn - column))
    }

    var minHeap = Heap<(index: Int, cost: UInt)> { $0.cost < $1.cost }
    minHeap.insert((index: startIndex, cost: heuristic(startIndex)))

    var costs = Array(repeating: UInt.max, count: flattenMatrix.count)
    costs[startIndex] = 0

    while let current = minHeap.pop() {
        guard current.index != endIndex else { break }

        for index in AdjacentPointsGenerator(current.index, rows: rows, columns: columns, includeDiagonals: false) {
            let cost = costs[current.index] + numericCast(flattenMatrix[index])
            if cost < costs[index] {
                costs[index] = cost
                let element = (index: index, cost: cost + heuristic(index))

                let replaced = minHeap.replace(with: element) { $0.index == element.index }
                if !replaced {
                    minHeap.insert(element)
                }
            }
        }
    }

    return costs[endIndex]
}
