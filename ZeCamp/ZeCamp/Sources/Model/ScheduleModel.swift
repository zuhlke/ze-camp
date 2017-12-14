import Foundation
import RxSwift

struct EventModel {
    var summary: EventSummary
    var details: Observable<Loadable<EventDetails>>
}

struct ScheduleModel {
    var events: [EventModel]
}
