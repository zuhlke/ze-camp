import Foundation

struct Event: Codable {
    let date: Date
    let durationInMinutes: Int
    let name: String
    let location: String
}

struct Schedule: Codable {
    let events: [Event]
}
