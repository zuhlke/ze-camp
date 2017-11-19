import XCTest
import RxBlocking
@testable import ZeCamp

class ResourceProviderTests: XCTestCase {
    
    private let resourceProvider = ResourceProvider(folder: "Content", in: Bundle(for: ZeCampTests.self))
    
    func testLoadingResources() {
        let result = resourceProvider.load(contentsOf: .sample).toBlocking().materialize()
        
        switch result {
        case .completed(let elements):
            XCTAssertEqual(elements, [
                "Read this!".data(using: .utf8)!,
                ])
            
        case .failed(_, let error):
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testMissingFileError() {
        let result = resourceProvider.load(contentsOf: .missing).toBlocking().materialize()
        
        switch result {
        case .completed(_):
            XCTFail("Should have thrown")

        case .failed(_, _):
            break // expected
        }
    }
    
}

private extension ResourceIdentifier {
    
    static let sample = ResourceIdentifier(name: "sample", extension: "txt")
    
    static let missing = ResourceIdentifier(name: "missing", extension: "txt")
    
}
