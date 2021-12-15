import Foundation

public struct Heap<T>: Sequence, CustomStringConvertible {
    private var elements: [T] = []
    private let sortFunction: (T, T) -> Bool

    public var isEmpty: Bool {
        elements.isEmpty
    }

    public var description: String {
        elements.description
    }

    public init(_ sortFunction: @escaping (T, T) -> Bool) {
        self.sortFunction = sortFunction
    }

    public mutating func insert(_ element: T) {
        elements.append(element)
        heapifyUp(from: elements.endIndex &- 1)
    }

    public func peek() -> T? {
        elements.first
    }

    public mutating func pop() -> T? {
        guard elements.count > 1 else {
            return elements.popLast()
        }

        let root = elements[elements.startIndex]
        elements[elements.startIndex] = elements.removeLast()

        heapifyDown(from: elements.startIndex)

        return root
    }

    @discardableResult
    public mutating func replace(with newElement: T, predicate: (T) throws -> Bool) rethrows -> Bool {
        guard let index = try elements.firstIndex(where: predicate) else { return false }

        if index == elements.endIndex &- 1 {
            elements.removeLast()
        } else {
            elements.swapAt(index, elements.endIndex &- 1)
            elements.removeLast()

            heapifyDown(from: index)
            heapifyUp(from: index)
        }

        insert(newElement)

        return true
    }

    public func makeIterator() -> AnyIterator<T> {
        var mutableSelf = self
        return AnyIterator {
            mutableSelf.pop()
        }
    }

    public func contains(where predicate: (T) throws -> Bool) rethrows -> Bool {
        try elements.contains(where: predicate)
    }

    // MARK: - Private

    private mutating func heapifyUp(from startIndex: Int) {
        var index = startIndex
        var parentIndex = Self.parent(of: index)
        while index > elements.startIndex && sortFunction(elements[index], elements[parentIndex]) {
            elements.swapAt(index, parentIndex)

            index = parentIndex
            parentIndex = Self.parent(of: index)
        }
    }

    private mutating func heapifyDown(from startIndex: Int) {
        var index: Int
        var swapIndex = startIndex
        repeat {
            index = swapIndex

            let leftChild = Self.leftChild(of: index)
            if leftChild < elements.endIndex && sortFunction(elements[leftChild], elements[swapIndex]) {
                swapIndex = leftChild
            }
            let rightChild = Self.rightChild(of: index)
            if rightChild < elements.endIndex && sortFunction(elements[rightChild], elements[swapIndex]) {
                swapIndex = rightChild
            }

            elements.swapAt(index, swapIndex)
        } while swapIndex != index
    }

    private static func parent(of index: Int) -> Int {
        (index &- 1) / 2
    }

    private static func leftChild(of index: Int) -> Int {
        index &* 2 &+ 1
    }

    private static func rightChild(of index: Int) -> Int {
        index &* 2 &+ 2
    }
}
