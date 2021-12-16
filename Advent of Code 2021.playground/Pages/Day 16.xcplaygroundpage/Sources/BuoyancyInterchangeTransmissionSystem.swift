import Foundation

public struct BuoyancyInterchangeTransmissionSystem {

    public struct NumericExpression {
        public let version: UInt8
        public let subExpressions: [NumericExpression]

        private let type: NumberOrOperator

        enum Operator {
            case sum, product, minimum, maximum, greaterThan, lessThan, equalTo
        }

        private enum NumberOrOperator {
            case number(UInt)
            case `operator`(Operator)
        }

        init(_ value: UInt, version: UInt8) {
            type = .number(value)
            subExpressions = []
            self.version = version
        }

        init(_ `operator`: Operator, subExpressions: [NumericExpression], version: UInt8) {
            type = .operator(`operator`)
            self.subExpressions = subExpressions
            self.version = version
        }

        public func evaluate() -> UInt {
            switch type {
            case .number(let number): return number
            case .operator(let `operator`):
                let values = subExpressions.map { $0.evaluate() }
                switch `operator` {
                case .sum: return values.reduce(0, +)
                case .product: return values.reduce(1, *)
                case .minimum: return values.min()!
                case .maximum: return values.max()!
                case .greaterThan: return values[0] > values[1] ? 1 : 0
                case .lessThan: return values[0] < values[1] ? 1 : 0
                case .equalTo: return values[0] == values[1] ? 1 : 0
                }
            }
        }
    }

    public static func decodeNumericExpression<S: StringProtocol>(from string: S) throws -> NumericExpression {
        var bitStream = DecodingBitstream(string)

        let (packet, count) = try bitStream.decodePacket()

        let padding = try bitStream.next(count % 4).cast(as: UInt8.self)
        assert(padding == 0, "Invalid padding")

        return packet
    }
}

private extension BuoyancyInterchangeTransmissionSystem {
    struct Bits {
        private var bits: [Bool] = []

        init<Bits>(leastSignificant bits: Bits) where Bits: Sequence, Bits.Element == Bool {
            self.bits = Array(bits)
        }

        init<Bits>(mostSignificant bits: Bits) where Bits: Sequence, Bits.Element == Bool {
            self.bits = Array(bits).reversed()
        }

        func cast<Integer>(as integerType: Integer.Type) -> Integer where Integer: FixedWidthInteger {
            assert(bits.count <= integerType.bitWidth)
            return bits.enumerated().reduce(into: Integer.zero) { partialResult, bit in
                if bit.element {
                    partialResult.setBit(bit.offset)
                }
            }
        }
    }

    struct DecodingBitstream {
        enum DecodingError: Error {
            case invalidInput
            case reachedEnd
        }

        var isEmpty: Bool {
            mutating get {
                if reachedEnd {
                    return true
                } else {
                    try? decodeNextCharacter()
                    return reachedEnd
                }
            }
        }

        private var bufferedBits: [Bool] = []
        private var characters: AnyIterator<Character>
        private var reachedEnd: Bool = false

        init<S: StringProtocol>(_ string: S) {
            characters = AnyIterator(string.makeIterator())
        }

        mutating func next(_ bits: Int = 1) throws -> Bits {
            assert(bits >= 0)
            while bufferedBits.count < bits {
                try decodeNextCharacter()
            }

            defer { bufferedBits.removeFirst(bits) }
            return Bits(mostSignificant: bufferedBits[..<bits])
        }

        private mutating func decodeNextCharacter() throws {
            guard let character = characters.next() else {
                reachedEnd = true
                throw DecodingError.reachedEnd
            }

            guard let bits = UInt8(String(character), radix: 16) else {
                throw DecodingError.invalidInput
            }

            let decodedCharacter = (0...3).map(bits.isBitSet)
            bufferedBits.append(contentsOf: decodedCharacter.reversed())
        }
    }
}

private extension BuoyancyInterchangeTransmissionSystem.DecodingBitstream {
    typealias NumericExpression = BuoyancyInterchangeTransmissionSystem.NumericExpression

    mutating func decodePacket() throws -> (NumericExpression, Int) {
        let version = try next(3).cast(as: UInt8.self)
        let type = try next(3).cast(as: UInt8.self)

        switch type {
        case 4:
            let (value, count) = try decodeNumber()
            return (NumericExpression(value, version: version), count)

        default:
            let `operator`: NumericExpression.Operator
            switch type {
            case 0: `operator` = .sum
            case 1: `operator` = .product
            case 2: `operator` = .minimum
            case 3: `operator` = .maximum
            case 5: `operator` = .greaterThan
            case 6: `operator` = .lessThan
            case 7: `operator` = .equalTo
            default: fatalError("Unknown operator: \(type)")
            }

            let (subPackets, count) = try decodeSubPackets()
            return (NumericExpression(`operator`, subExpressions: subPackets, version: version), count)
        }
    }

    mutating func decodeNumber() throws -> (UInt, Int) {
        var halfBytes: [UInt8] = []
        repeat {
            let halfByte = try next(5).cast(as: UInt8.self)
            halfBytes.append(halfByte)
        } while halfBytes[halfBytes.count - 1].isBitSet(4)

        let value: UInt = halfBytes.reversed().enumerated().reduce(into: .zero) { partialResult, halfByte in
            let offset = halfByte.offset * 4
            var halfByte = halfByte.element
            halfByte.unsetBit(4)
            partialResult |= (numericCast(halfByte) << offset)
        }

        return (value, halfBytes.count * 5 + 6)
    }

    mutating func decodeSubPackets() throws -> ([NumericExpression], Int) {
        let bit = try next().cast(as: UInt8.self)
        if bit == 0 {
            let length = try next(15).cast(as: UInt16.self)
            return try decodeSubPackets(length: length)
        } else {
            let count = try next(11).cast(as: UInt16.self)
            return try decodeSubPackets(count: count)
        }
    }

    mutating func decodeSubPackets(count: UInt16) throws -> ([NumericExpression], Int) {
        var numberOfBits = 0
        var packets: [NumericExpression] = []
        for _ in 1...count {
            let (packet, length) = try decodePacket()
            numberOfBits += length
            packets.append(packet)
        }

        return (packets, numberOfBits + 18)
    }

    mutating func decodeSubPackets(length: UInt16) throws -> ([NumericExpression], Int) {
        var numberOfBits = 0
        var packets: [NumericExpression] = []
        while numberOfBits < length {
            let (packet, length) = try decodePacket()
            numberOfBits += length
            packets.append(packet)
        }
        assert(numberOfBits == length, "Sub-packets length mismatch: expected \(length) but got \(numberOfBits)")

        return (packets, numberOfBits + 22)
    }
}
