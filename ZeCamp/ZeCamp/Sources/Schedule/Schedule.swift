import Foundation

struct Event: Codable {
    let date: Date
    let durationInMinutes: Int
    let name: String
    let location: String
    let id: Int
}

struct Schedule: Codable {
    let events: [Event]
}
