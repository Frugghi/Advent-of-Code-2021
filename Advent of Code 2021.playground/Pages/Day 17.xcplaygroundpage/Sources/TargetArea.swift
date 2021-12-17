import Foundation

public struct TargetArea: LosslessStringConvertible {
    public let xRange: ClosedRange<Int>
    public let yRange: ClosedRange<Int>

    public var description: String {
        "target area: x=\(xRange), y=\(yRange)"
    }

    public init?(_ string: String) {
        let values = string.split(separator: ":").last!.split(separator: ",")
        var xRange = 0...0
        var yRange = 0...0

        for value in values {
            let components = value.trimmingCharacters(in: .whitespaces).split { $0 == "=" || $0 == "." }
            let firstValue = Int(components[1])!
            let secondValue = Int(components[2])!
            let range = min(firstValue, secondValue)...max(firstValue, secondValue)
            if components[0] == "x" {
                xRange = range
            } else if components[0] == "y" {
                yRange = range
            }
        }

        self.xRange = xRange
        self.yRange = yRange
    }
}
