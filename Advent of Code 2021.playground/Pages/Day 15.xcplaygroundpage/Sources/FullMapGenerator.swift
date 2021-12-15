import Foundation

public extension Array {

    func repeating<T>(times: Int) -> AnySequence<[T]> where Element == [T], T: FixedWidthInteger {
        let input = self
        return AnySequence(
            (0..<input.count * times).lazy.map { y in
                (0..<input[0].count * times).lazy.map { x in
                    let vertical = y.quotientAndRemainder(dividingBy: input.count)
                    let horizontal = x.quotientAndRemainder(dividingBy: input[0].count)
                    let increase: T = numericCast(vertical.quotient + horizontal.quotient)
                    return 1 + (input[vertical.remainder][horizontal.remainder] + increase - 1) % 9
                }
            }
        )
    }
}
