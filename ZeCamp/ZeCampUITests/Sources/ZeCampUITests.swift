import XCTest

class ZeCampUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        XCUIApplication().launch()
    }

    func testExample() {
        // Keep so we have *some test* for Xcode to run until we have a real test
    }
    
}
