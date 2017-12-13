import Foundation
import RxSwift

struct AppModel {
    
    enum Errors: Error {
        case missingScheduleFile
        case missingDetails(id: Int)
    }
    
    var schedule: Observable<Loadable<ScheduleModel>>
    var eventDetailsForId: Observable<Loadable<(Int) -> EventDetails?>>
    
    init(resourceProvider: ResourceProvider) {
        
        let eventDetails: Observable<Loadable<[EventDetails]>> = resourceProvider.load(contentsOf: .eventDetails).map { data in
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            return .loaded(try decoder.decode(DetailsList.self, from: data).details)
        }.startWith(.loading).share(replay: 1, scope: .forever)
        
        eventDetailsForId = eventDetails.map { loaded in
            return loaded.map { details in
                return { id in
                    details.first { id == $0.id }
                }
            }
        }
        
        schedule = resourceProvider.load(contentsOf: .schedule).map { data in
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let schedule = try decoder.decode(Schedule.self, from: data)
            let events = schedule.events.map { summary in
                return EventModel(summary: summary, details: eventDetails.map { detailLoadable in
                    switch detailLoadable {
                    case .loading:
                        return .loading
                    case .loaded(let details):
                        guard let detail = details.first(where: { summary.id == $0.id }) else {
                            throw Errors.missingDetails(id: summary.id)
                        }
                        return .loaded(detail)
                    }
                })
            }
            let scheduleModel = ScheduleModel(events: events)
            return .loaded(scheduleModel)
        }.startWith(.loading)
    }
    
}

private extension ResourceIdentifier {
    
    static let schedule = ResourceIdentifier(name: "schedule", extension: "json")
    
    static let eventDetails = ResourceIdentifier(name: "eventDetails", extension: "json")
}
