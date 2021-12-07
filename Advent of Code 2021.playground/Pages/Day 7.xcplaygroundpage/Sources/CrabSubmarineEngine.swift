import Foundation

public protocol CrabSubmarineEngine {
    var fuelConsumptionRate: UInt { get }

    mutating func adjustFuelConsumptionRate(_ newCrabs: UInt)
}
