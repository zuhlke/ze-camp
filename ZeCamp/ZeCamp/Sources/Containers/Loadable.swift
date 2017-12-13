import Foundation

enum Loadable<Element> {
    case loading
    case loaded(Element)
}
