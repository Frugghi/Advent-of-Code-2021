import Foundation

public struct BuoyancyInterchangeTransmissionSystem {

    public enum NumericExpression {
        indirect case sum(version: UInt8, [NumericExpression])
        indirect case product(version: UInt8, [NumericExpression])
        indirect case minimum(version: UInt8, [NumericExpression])
        indirect case maximum(version: UInt8, [NumericExpression])
        case number(version: UInt8, value: UInt)
        indirect case greaterThan(version: UInt8, NumericExpression, NumericExpression)
        indirect case lessThan(version: UInt8, NumericExpression, NumericExpression)
        indirect case equalTo(version: UInt8, NumericExpression, NumericExpression)

        public var version: UInt8 {
            switch self {
            case .sum(let version, _),
                 .product(let version, _),
                 .minimum(let version, _),
                 .maximum(let version, _),
                 .number(let version, _),
                 .greaterThan(let version, _, _),
                 .lessThan(let version, _, _),
                 .equalTo(let version, _, _):
                return version
            }
        }

        public func evaluate() -> UInt {
            switch self {
            case .sum(_, let expressions): return expressions.map { $0.evaluate() }.reduce(0, +)
            case .product(_, let expressions): return expressions.map { $0.evaluate() }.reduce(1, *)
            case .minimum(_, let expressions): return expressions.map { $0.evaluate() }.min()!
            case .maximum(_, let expressions): return expressions.map { $0.evaluate() }.max()!
            case .number(_, let value): return value
            case .greaterThan(_, let lhs, let rhs): return lhs.evaluate() > rhs.evaluate() ? 1 : 0
            case .lessThan(_, let lhs, let rhs): return lhs.evaluate() < rhs.evaluate() ? 1 : 0
            case .equalTo(_, let lhs, let rhs): return lhs.evaluate() == rhs.evaluate() ? 1 : 0
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
        case 0:
            let (subPackets, count) = try decodeSubPackets()
            return (.sum(version: version, subPackets), count)

        case 1:
            let (subPackets, count) = try decodeSubPackets()
            return (.product(version: version, subPackets), count)

        case 2:
            let (subPackets, count) = try decodeSubPackets()
            return (.minimum(version: version, subPackets), count)

        case 3:
            let (subPackets, count) = try decodeSubPackets()
            return (.maximum(version: version, subPackets), count)

        case 4:
            let (value, count) = try decodeNumber()
            return (.number(version: version, value: value), count)

        case 5:
            let (subPackets, count) = try decodeSubPackets()
            assert(subPackets.count == 2)
            return (.greaterThan(version: version, subPackets[0], subPackets[1]), count)

        case 6:
            let (subPackets, count) = try decodeSubPackets()
            assert(subPackets.count == 2)
            return (.lessThan(version: version, subPackets[0], subPackets[1]), count)

        case 7:
            let (subPackets, count) = try decodeSubPackets()
            assert(subPackets.count == 2)
            return (.equalTo(version: version, subPackets[0], subPackets[1]), count)

        default:
            fatalError("Unknown type: \(type)")
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
