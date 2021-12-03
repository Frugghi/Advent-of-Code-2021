import Foundation

public extension FixedWidthInteger {
    func isBitSet(_ index: Int) -> Bool {
        (self >> index) & 1 == 1
    }

    func truncateBits(after index: Int) -> Self {
        (self << (bitWidth - index)) >> (bitWidth - index)
    }
}
