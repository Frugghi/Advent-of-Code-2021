import Foundation

public struct BinaryStringParseStrategy<T>: ParseStrategy where T: FixedWidthInteger {
    public typealias ParseInput = String
    public typealias ParseOutput = T

    public init() {}

    public func parse(_ value: ParseInput) throws -> ParseOutput {
        guard value.count <= ParseOutput.bitWidth else {
            throw POSIXError(.EOVERFLOW)
        }

        return try value.reversed().enumerated().reduce(into: .zero) { partialResult, bit in
            switch bit.element {
            case "0": break
            case "1": partialResult |= 1 << bit.offset
            default: throw POSIXError(.EINVAL)
            }
        }
    }
}
