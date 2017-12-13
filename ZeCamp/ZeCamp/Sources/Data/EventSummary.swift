import Foundation

struct EventDetails: Codable {
    let header: String
    let info: String
    let id: Int
}

struct DetailsList: Codable {
    let details: [EventDetails]
}

struct EventSummary: Codable {
    let date: Date
    let durationInMinutes: Int
    let name: String
    let location: String
    let id: Int
}
