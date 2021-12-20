import Foundation

public final class SnailfishNumber: LosslessStringConvertible {
    private enum PairOrNumber {
        case pair(left: SnailfishNumber, right: SnailfishNumber)
        case number(UInt)

        var isPair: Bool {
            if case .pair = self {
                return true
            } else {
                return false
            }
        }
    }

    private var value: PairOrNumber

    public var description: String {
        switch value {
        case .pair(let left, let right): return "[\(left),\(right)]"
        case .number(let value): return value.description
        }
    }

    public var magnitude: UInt {
        switch value {
        case .pair(let left, let right): return 3 * left.magnitude + 2 * right.magnitude
        case .number(let value): return value
        }
    }

    public init?(_ string: String) {
        var stack: [SnailfishNumber] = []
        for character in string where character != "," && character != "[" {
            switch character {
            case "]":
                guard stack.count >= 2 else { return nil }
                let right = stack.removeLast()
                let left = stack.removeLast()
                stack.append(.pair(left, right))

            case let character where character.isNumber:
                guard let value = UInt(String(character)) else { return nil }
                stack.append(.literal(value))

            default:
                return nil
            }
        }

        guard stack.count == 1 else { return nil }

        self.value = stack.removeLast().value
    }

    public init(_ other: SnailfishNumber) {
        switch other.value {
        case .pair(let left, let right): self.value = .pair(left: SnailfishNumber(left), right: SnailfishNumber(right))
        case .number(let number): self.value = .number(number)
        }
    }

    private static func literal(_ value: UInt) -> SnailfishNumber {
        .init(.number(value))
    }

    private static func pair(_ left: SnailfishNumber, _ right: SnailfishNumber) -> SnailfishNumber {
        .init(.pair(left: left, right: right))
    }

    private init(_ value: PairOrNumber) {
        self.value = value
    }

    private func nodes() -> AnySequence<SnailfishNumber> {
        AnySequence { () -> AnyIterator<SnailfishNumber> in
            var stack = [self]
            return AnyIterator {
                guard let node = stack.popLast() else { return nil }

                if case .pair(let left, let right) = node.value {
                    stack.append(contentsOf: [right, left])
                }

                return node
            }
        }
    }

    private func nodesAndAncestors() -> AnySequence<(node: SnailfishNumber, ancestors: [SnailfishNumber])> {
        AnySequence { () -> AnyIterator<(node: SnailfishNumber, ancestors: [SnailfishNumber])> in
            var stack: [(node: SnailfishNumber, ancestors: [SnailfishNumber])] = [(self, [])]
            return AnyIterator {
                guard let last = stack.popLast() else { return nil }

                if case .pair(let left, let right) = last.node.value {
                    let ancestors = last.ancestors + CollectionOfOne(last.node)
                    stack.append(contentsOf: [(right, ancestors), (left, ancestors)])
                }

                return last
            }
        }
    }

    private func explode() -> Bool {
        let nodeToExplode = nodesAndAncestors().first { (node, ancestors) in
            node.value.isPair && ancestors.count >= 4
        }

        guard let nodeToExplode = nodeToExplode, case .pair(let left, let right) = nodeToExplode.node.value else {
            return false
        }

        assert(!left.value.isPair, "Cannot explode node \(nodeToExplode.node)")
        assert(!right.value.isPair, "Cannot explode node \(nodeToExplode.node)")

        let nodes = nodeToExplode.ancestors + CollectionOfOne(nodeToExplode.node)
        if case .number(let leftValue) = left.value,
           let node = findExplodeToNode(onLeft: true, nodes: nodes),
           case .number(let value) = node.value {
            node.value = .number(value + leftValue)
        }

        if case .number(let rightValue) = right.value,
           let node = findExplodeToNode(onLeft: false, nodes: nodes),
           case .number(let value) = node.value {
            node.value = .number(value + rightValue)
        }

        guard let parent = nodeToExplode.ancestors.last, case .pair(let left, let right) = parent.value else {
            fatalError("Parent pair node must exist")
        }

        if left === nodeToExplode.node {
            parent.value = .pair(left: .literal(0), right: right)
        } else {
            parent.value = .pair(left: left, right: .literal(0))
        }

        return true
    }

    private func findExplodeToNode(onLeft: Bool, nodes: [SnailfishNumber]) -> SnailfishNumber? {
        let indexOfAncestor = nodes.indices.dropLast().reversed().first { index in
            guard case .pair(let left, let right) = nodes[index].value else { return false }

            return nodes[index + 1] !== (onLeft ? left : right)
        }

        guard case .pair(let left, let right) = indexOfAncestor.map({ nodes[$0] })?.value else { return nil }

        var node = (onLeft ? left : right)
        while case .pair(let left, let right) = node.value {
            node = (onLeft ? right : left)
        }

        return node
    }

    private func split() -> Bool {
        for node in nodes() {
            if case .number(let value) = node.value, value >= 10 {
                let (quotient, remainder) = value.quotientAndRemainder(dividingBy: 2)
                node.value = .pair(left: .literal(quotient), right: .literal(quotient + remainder))
                return true
            }
        }

        return false
    }

    public static func + (lhs: SnailfishNumber, rhs: SnailfishNumber) -> SnailfishNumber {
        let sum: SnailfishNumber = .pair(SnailfishNumber(lhs), SnailfishNumber(rhs))

        var reduced = true
        repeat {
            reduced = !sum.explode()

            guard reduced else { continue }

            reduced = !sum.split()
        } while !reduced

        return sum
    }
}
