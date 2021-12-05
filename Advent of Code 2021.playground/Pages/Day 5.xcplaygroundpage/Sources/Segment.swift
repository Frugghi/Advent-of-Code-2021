import Foundation

public struct Segment: Equatable, LosslessStringConvertible, Sequence {
    public struct Point: Equatable, Hashable {
        public let x: Int
        public let y: Int

        func next(towards point: Point) -> Point? {
            guard self != point else { return nil }

            let x: Int
            if self.x == point.x {
                x = point.x
            } else if self.x > point.x {
                x = self.x - 1
            } else {
                x = self.x + 1
            }

            let y: Int
            if self.y == point.y {
                y = point.y
            } else if self.y > point.y {
                y = self.y - 1
            } else {
                y = self.y + 1
            }

            return Point(x: x, y: y)
        }
    }

    public let start: Point
    public let end: Point

    public var isHorizontal: Bool {
        start.y == end.y
    }

    public var isVertical: Bool {
        start.x == end.x
    }

    public var description: String {
        "\(start.x),\(start.y) -> \(end.x),\(end.y)"
    }

    public init?(_ description: String) {
        let components = description.split(omittingEmptySubsequences: true, whereSeparator: { character in
            character == "," || character == "-" || character == ">"
        }).compactMap { string -> Int? in
            Int(string.trimmingCharacters(in: .whitespacesAndNewlines))
        }

        guard components.count == 4 else { return nil }

        start = Point(x: components[0], y: components[1])
        end = Point(x: components[2], y: components[3])
    }

    public func makeIterator() -> AnyIterator<Point> {
        var point: Point? = start
        return AnyIterator<Point> {
            defer {
                point = point?.next(towards: end)
            }
            return point
        }
    }
}
