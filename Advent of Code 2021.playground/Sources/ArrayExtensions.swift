import Foundation

public extension Array where Element: LosslessStringConvertible {
    init(from fileName: String, bundle: Bundle = .main, separator: Character = "\n") throws {
        guard let url = bundle.url(forResource: fileName, withExtension: nil) else {
            throw URLError(.fileDoesNotExist)
        }

        self = try String(contentsOf: url)
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
