import Foundation

public struct Point: Hashable {
    public var x: Int
    public var y: Int

    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }

    public init?(_ string: String) {
        let components = string.split(separator: ",")
        guard components.count == 2, let x = Int(components[0]), let y = Int(components[1]) else {
            return nil
        }
        self.init(x: x, y: y)
    }
}
