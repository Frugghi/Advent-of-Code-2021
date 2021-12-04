import Foundation

public struct BingoBoard {
    private var rows: [Set<Int>]
    private var columns: [Set<Int>]

    public init<Input>(input: Input) throws where Input: Collection, Input.Element: StringProtocol {
        guard input.count == 5 else { throw POSIXError(.EINVAL) }

        var columns: [Set<Int>] = Array(repeating: [], count: 5)
        var rows: [Set<Int>] = []

        for row in input {
            let row: [Int] = try row.split(separator: " ", omittingEmptySubsequences: true).map {
                guard let number = Int($0) else { throw POSIXError(.EINVAL) }
                return number
            }

            try row.enumerated().forEach {
                guard columns[$0.offset].insert($0.element).inserted else {
                    throw POSIXError(.EINVAL)
                }
            }

            let rowAsSet = Set(row)
            guard rowAsSet.count == row.count else {
                throw POSIXError(.EINVAL)
            }
            rows.append(rowAsSet)
        }

        self.rows = rows
        self.columns = columns
    }

    public mutating func markNumber(_ number: Int) -> Int? {
        var isBingo: Bool = false
        for index in rows.indices where rows[index].remove(number) != nil && rows[index].isEmpty {
            isBingo = true
        }
        for index in columns.indices where columns[index].remove(number) != nil && columns[index].isEmpty {
            isBingo = true
        }

        guard isBingo else {
            return nil
        }

        return rows.map({ $0.reduce(0, +) }).reduce(0, +) * number
    }
}
