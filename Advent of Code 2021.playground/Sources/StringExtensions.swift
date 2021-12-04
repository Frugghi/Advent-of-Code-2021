import Foundation

public extension String {
    init(contentsOf fileName: String, bundle: Bundle = .main) throws {
        guard let url = bundle.url(forResource: fileName, withExtension: nil) else {
            throw URLError(.fileDoesNotExist)
        }

        try self.init(contentsOf: url)
    }
}
