import Foundation

public struct Point<T> {
    public let x: T
    public let y: T

    public init(x: T, y: T) {
        self.x = x
        self.y = y
    }
}

extension Point: Equatable where T: Equatable {}
extension Point: Hashable where T: Hashable {}
