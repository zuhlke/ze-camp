import Foundation

enum Loadable<Element> {
    case loading
    case loaded(Element)
}

extension Loadable {
    func map<To>(transform: (Element) -> To) -> Loadable<To> {
        switch self {
        case .loading:
            return .loading
        case .loaded(let element):
            return .loaded(transform(element))
        }
    }
    
    func flatMap<To>(transform: (Element) -> Loadable<To>) -> Loadable<To> {
        switch map(transform: transform) {
        case .loading:
            return .loading
        case .loaded(let element):
            switch element {
            case .loading:
                return .loading
            case .loaded(let nestedElement):
                return .loaded(nestedElement)
            }
        }
    }
}
