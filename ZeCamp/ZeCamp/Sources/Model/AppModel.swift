import Foundation
import RxSwift

struct AppModel {
    
    enum Errors: Error {
        case missingScheduleFile
    }
    
    var schedule: Observable<Loadable<Schedule>>
    var eventDetailsForId: Observable<Loadable<(Int) -> EventDetails?>>
    
    init(resourceProvider: ResourceProvider) {
        
        let eventDetails: Observable<Loadable<[EventDetails]>> = resourceProvider.load(contentsOf: .eventDetails).map { data in
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            return .loaded(try decoder.decode(DetailsList.self, from: data).details)
        }.startWith(.loading).shareReplay(1)
        
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
            
            return .loaded(try decoder.decode(Schedule.self, from: data))
        }.startWith(.loading)
    }
    
}

private extension ResourceIdentifier {
    
    static let schedule = ResourceIdentifier(name: "schedule", extension: "json")
    
    static let eventDetails = ResourceIdentifier(name: "eventDetails", extension: "json")
}
