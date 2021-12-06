import Foundation

@dynamicMemberLookup
public struct Input {
    public let fileName: String

    public init(fileName: String) {
        self.fileName = fileName
    }

    public func load<T>(
        as type: [T].Type,
        separators: Set<Character> = ["\n"],
        bundle: Bundle = .main
    ) throws -> [T] where T: LosslessStringConvertible {
        guard let url = bundle.url(forResource: fileName, withExtension: nil) else {
            throw URLError(.fileDoesNotExist)
        }

        return try String(contentsOf: url)
            .split(omittingEmptySubsequences: true, whereSeparator: separators.contains)
            .map(String.init)
            .map { string -> T in
                guard let value = T(string) else {
                    throw URLError(.cannotParseResponse)
                }

                return value
            }
    }

    public static subscript(dynamicMember member: String) -> Input {
        var day = member
        day.insert("_", at: day.index(day.startIndex, offsetBy: 3))
        return .init(fileName: "\(day)_input")
    }
}
