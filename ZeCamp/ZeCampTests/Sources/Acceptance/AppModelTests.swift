import XCTest
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
    
}
