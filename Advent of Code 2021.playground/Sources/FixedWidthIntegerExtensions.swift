import Foundation

public extension FixedWidthInteger {
    func isBitSet(_ index: Int) -> Bool {
        (self >> index) & 1 == 1
    }

    mutating func setBit(_ index: Int) {
        self |= (1 << index)
    }

    mutating func unsetBit(_ index: Int) {
        self &= ~(1 << index)
    }

    func truncateBits(after index: Int) -> Self {
        (self << (bitWidth - index)) >> (bitWidth - index)
    }
}
