import Foundation

public struct FuelConsumption: IteratorProtocol {
    private let input: [Int: UInt]
    private var iterator: AnyIterator<Int>
    private var fuelConsumption: UInt = 0
    public private(set) var engine: CrabSubmarineEngine

    public init<C>(range: C, input: [Int: UInt], engine: CrabSubmarineEngine) where C: Collection, C.Element == Int {
        iterator = AnyIterator(range.makeIterator())
        self.input = input
        self.engine = engine
    }

    public mutating func next() -> (index: Int, fuelConsumption: UInt)? {
        guard let index = iterator.next() else { return nil }

        defer {
            engine.adjustFuelConsumptionRate(input[index, default: 0])
            fuelConsumption += engine.fuelConsumptionRate
        }

        return (index, fuelConsumption)
    }
}
