import Foundation
import Vision
#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

public final class DotsRenderer: CustomStringConvertible, CustomPlaygroundDisplayConvertible {
    private let points: Set<Point>
    private let maxX: Int
    private let maxY: Int

    public private(set) lazy var description: String = {
        if let ocrString = ocr() {
            return ocrString
        } else {
            var matrix = Array(repeating: Array(repeating: " ", count: maxX + 1), count: maxY + 1)
            for point in points {
                matrix[point.y][point.x] = "█"
            }
            return matrix.map { $0.joined(separator: "") }.joined(separator: "\n")
        }
    }()

    public var playgroundDescription: Any {
        renderImage(usingCircles: true) as Any
    }

    public init<S>(dots: S) where S: Sequence, S.Element == Point {
        let points = Set(dots)
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

    private func ocr() -> String? {
        guard let cgImage = renderImage(usingCircles: false) else { return nil }

        var result: String?
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        let request = VNRecognizeTextRequest { request, _ in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                return
            }

            let recognizedStrings: [String] = observations.compactMap { observation in
                observation.topCandidates(1).first?.string.trimmingCharacters(in: .whitespaces)
            }

            if !recognizedStrings.isEmpty {
                result = recognizedStrings.joined(separator: "")
            }
        }
        request.recognitionLevel = .fast

        do {
            try requestHandler.perform([request])
        } catch {}

        return result
    }

    private func renderImage(usingCircles circles: Bool) -> CGImage? {
        let dotSize = CGSize(width: 8, height: 8)
        let spacing: CGFloat = circles ? 4 : 0
        let horizontalInset: CGFloat = 12
        let verticalInset: CGFloat = 12
        let width = CGFloat(maxX + 1) * dotSize.width + CGFloat(maxX) * spacing + horizontalInset * 2
        let height = CGFloat(maxY + 1) * dotSize.height + CGFloat(maxY) * spacing + verticalInset * 2
        let draw = { [points] (context: CGContext) in
            for point in points {
                let rect = CGRect(
                    origin: CGPoint(
                        x: horizontalInset + CGFloat(point.x) * dotSize.width + CGFloat(point.x) * spacing,
                        y: verticalInset + CGFloat(point.y) * dotSize.height + CGFloat(point.y) * spacing
                    ),
                    size: dotSize
                )

                circles ? context.fillEllipse(in: rect) : context.fill(rect)
            }
        }
#if canImport(UIKIt)
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height))
        return renderer.image { context in
            UIColor.white.setFill()
            draw(context.cgContext)
        }.cgImage
#else
        return NSImage(size: .init(width: width, height: height), flipped: false) { rect in
            NSGraphicsContext.saveGraphicsState()
            NSColor.white.setFill()

            var transform = AffineTransform()
            transform.translate(x: 0, y: height)
            transform.scale(x: 1, y: -1)
            (transform as NSAffineTransform).concat()

            draw(NSGraphicsContext.current!.cgContext)

            NSGraphicsContext.restoreGraphicsState()
            return true
        }.cgImage(forProposedRect: nil, context: nil, hints: nil)
#endif
    }
}
