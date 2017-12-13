import Foundation
import RxSwift

struct AppModel {
    
    enum Errors: Error {
        case missingScheduleFile
    }
    
    var schedule: Observable<Loadable<Schedule>>
    
    init(resourceProvider: ResourceProvider) {
        schedule = resourceProvider.load(contentsOf: .schedule).map { data in
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            return .loaded(try decoder.decode(Schedule.self, from: data))
        }.startWith(.loading)
    }
    
}

private extension ResourceIdentifier {
    
    static let schedule = ResourceIdentifier(name: "schedule", extension: "json")
    
}
