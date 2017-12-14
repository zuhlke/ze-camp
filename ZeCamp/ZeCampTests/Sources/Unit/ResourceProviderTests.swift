import XCTest
@testable import ZeCamp

class ResourceProviderTests: XCTestCase {
    
    private let resourceProvider = ResourceProvider(folder: "Content", in: Bundle(for: ZeCampTests.self))
    
    func testLoadingResources() {
        XCTAssert(
            snapshotsOf: resourceProvider.load(contentsOf: .sample),
            match: [
                .next(try! Data(contentsOf: ResourceIdentifier.sample.testURL()) ),
                .completed()
            ],
            timeOut: .never
        )
    }
    
    func testMissingFileError() {
        XCTAssert(
            snapshotsOf: resourceProvider.load(contentsOf: .missing),
            match: [
                .error()
            ],
            timeOut: .never
        )
    }
    
}

private extension ResourceIdentifier {
    
    static let sample = ResourceIdentifier(name: "sample", extension: "txt")
    
    static let missing = ResourceIdentifier(name: "missing", extension: "txt")
    
    func testURL() -> URL {
        return Bundle(for: ZeCampTests.self)
            .url(forResource: name, withExtension: self.extension, subdirectory: "Content")!
    }
    
}
