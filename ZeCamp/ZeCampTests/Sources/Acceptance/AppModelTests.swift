import XCTest
import RxSwift
@testable import ZeCamp

class AppModelTests: XCTestCase {
    
    func testFailingToLoadSchedule() {
        let resourceProvider = ResourceProvider(folder: "NonExistentContent", in: Bundle(for: type(of: self)))
        let model = AppModel(resourceProvider: resourceProvider)
        
        XCTAssert(
            snapshotsOf: model.schedule,
            match: [
                .next(verify: { loadable in
                    switch loadable {
                    case .loading: break
                    case .loaded(_): XCTFail("Unexpected loaded value")
                    }
                }),
                .error()
            ],
            timeOut: .never
        )
    }
    
    func testLoadingSchedule() {
        let resourceProvider = ResourceProvider(folder: "Content", in: Bundle(for: type(of: self)))
        let model = AppModel(resourceProvider: resourceProvider)
        
        XCTAssert(
            snapshotsOf: model.schedule,
            match: [
                .next(verify: { loadable in
                    switch loadable {
                    case .loading: break
                    case .loaded(_): XCTFail("Unexpected loaded value")
                    }
                }),
                .next(verify: { loadable in
                    switch loadable {
                    case .loading: XCTFail("Unexpected loaded value")
                    case .loaded(let schedule):
                        XCTAssertEqual(schedule.events.count, 1)
                    }
                }),
                .completed()
            ],
            timeOut: .never
        )
    }
    
    func testFirstEventDetailExists() {
        let resourceProvider = ResourceProvider(folder: "Content", in: Bundle(for: type(of: self)))
        let model = AppModel(resourceProvider: resourceProvider)
        
        let details = model.schedule.flatMap { model -> Observable<Loadable<EventDetails>> in
            switch model {
            case .loading:
                return Observable.empty()
            case .loaded(let schedule):
                return schedule.events[0].details
            }
        }
        
        XCTAssert(
            snapshotsOf: details,
            match: [
                .next(verify: { loadable in
                    switch loadable {
                    case .loading: break
                    case .loaded(_): XCTFail("Unexpected loaded value")
                    }
                }),
                .next(verify: { loadable in
                    switch loadable {
                    case .loading: XCTFail("Unexpected loaded value")
                    case .loaded(let eventDetails):
                        XCTAssertEqual(eventDetails.info, "xxx")
                    }
                }),
                .completed()
            ],
            timeOut: .never
        )
        
    }
    
}
