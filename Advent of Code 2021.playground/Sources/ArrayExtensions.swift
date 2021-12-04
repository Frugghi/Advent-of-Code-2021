import Foundation

public extension Array where Element: LosslessStringConvertible {
    init(from fileName: String, bundle: Bundle = .main, separator: Character = "\n") throws {
        self = try String(contentsOf: fileName, bundle: bundle)
            .split(separator: separator, omittingEmptySubsequences: true)
            .map(String.init)
            .map { string in
                guard let value = Element(string) else {
                    throw URLError(.cannotParseResponse)
                }

                return value
            }
    }
}
