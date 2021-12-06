import Foundation

public extension Array where Element: LosslessStringConvertible {
    init(from fileName: String, bundle: Bundle = .main, separator: Character) throws {
        try self.init(from: fileName, bundle: bundle, separators: [separator])
    }

    init(from fileName: String, bundle: Bundle = .main, separators: Set<Character> = ["\n"]) throws {
        self = try String(contentsOf: fileName, bundle: bundle)
            .split(omittingEmptySubsequences: true, whereSeparator: separators.contains)
            .map(String.init)
            .map { string in
                guard let value = Element(string) else {
                    throw URLError(.cannotParseResponse)
                }

                return value
            }
    }
}
