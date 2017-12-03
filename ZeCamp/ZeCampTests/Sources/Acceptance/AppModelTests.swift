import XCTest
import RxBlocking
@testable import ZeCamp

class AppModelTests: XCTestCase {
    
    func testFailingToLoadSchedule() {
        let resourceProvider = ResourceProvider(folder: "NonExistentContent", in: Bundle(for: type(of: self)))
        let model = AppModel(resourceProvider: resourceProvider)
        
        let result = model.schedule.toBlocking(timeout: 1).materialize()
        
        switch result {
        case .completed(_):
            XCTFail("Should not complete")
        case .failed(let elements, _):
            XCTAssertEqual(elements.count, 1)
        }
    }
    
    func testLoadingSchedule() {
        let resourceProvider = ResourceProvider(folder: "Content", in: Bundle(for: type(of: self)))
        let model = AppModel(resourceProvider: resourceProvider)
        
        let result = model.schedule.toBlocking(timeout: 1).materialize()
        
        switch result {
        case .completed(let elements):
            XCTAssertEqual(elements.count, 2)
        case .failed(_, _):
            XCTFail("Should not fail")
        }
    }
    
}
