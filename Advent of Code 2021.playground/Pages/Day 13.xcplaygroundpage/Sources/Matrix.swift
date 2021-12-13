import Foundation
import UIKit

public struct Matrix: CustomStringConvertible, CustomPlaygroundDisplayConvertible {
    private let points: [Point]
    private let maxX: Int
    private let maxY: Int

    public var description: String {
        var matrix = Array(repeating: Array(repeating: " ", count: maxX + 1), count: maxY + 1)
        for point in points {
            matrix[point.y][point.x] = "█"
        }
        return matrix.map { $0.joined(separator: "") }.joined(separator: "\n")
    }

    public var playgroundDescription: Any {
        let dotSize = CGSize(width: 8, height: 8)
        let spacing: CGFloat = 4
        let horizontalInset: CGFloat = 12
        let verticalInset: CGFloat = 12
        let width = CGFloat(maxX + 1) * dotSize.width + CGFloat(maxX) * spacing + horizontalInset * 2
        let height = CGFloat(maxY + 1) * dotSize.height + CGFloat(maxY) * spacing + verticalInset * 2
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height))
        return renderer.image { context in
            UIColor.white.setFill()
            for point in points {
                let rect = CGRect(
                    origin: CGPoint(
                        x: horizontalInset + CGFloat(point.x) * dotSize.width + CGFloat(point.x) * spacing,
                        y: verticalInset + CGFloat(point.y) * dotSize.height + CGFloat(point.y) * spacing
                    ),
                    size: dotSize
                )
                context.cgContext.fillEllipse(in: rect)
            }
        }
    }

    public init(points: [Point]) {
        var maxX: Int = 0
        var maxY: Int = 0
        for point in points {
            maxX = max(maxX, point.x)
            maxY = max(maxY, point.y)
        }

        self.points = points
        self.maxX = maxX
        self.maxY = maxY
    }

}
