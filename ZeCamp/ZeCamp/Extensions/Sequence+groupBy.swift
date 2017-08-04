import Foundation

public extension Sequence {
    func group<U: Hashable>(by key: (Iterator.Element) -> U) -> [U:[Iterator.Element]] {
        var categories: [U: [Iterator.Element]] = [:]
        for element in self {
            let key = key(element)
            if categories[key]?.append(element) == nil {
                categories[key] = [element]
            }
        }
        return categories
    }
}
