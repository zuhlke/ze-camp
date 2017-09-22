import Foundation

struct EventDetails: Codable {
    let header: String
    let info: String
    let id: Int
}

struct DetailsList: Codable {
    let details: [EventDetails]
}
