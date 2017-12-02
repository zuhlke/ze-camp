import XCTest
import RxSwift
@testable import ZeCamp

class XCTestCaseObservableSnapshotsTests: XCTestCase {
    
    func testThatAVerifierIsCalledForEachEvent() {
        let elements = [1, 2, 3, 4]
        let observable = Observable.from(elements)
        
        var callbackCount = 0
        var verifiers = elements.map { expected in
            return SnapshotVerifier<Int> { snapshot in
                callbackCount += 1
                switch snapshot.event {
                case .next(let element):
                    XCTAssertEqual(expected, element)
                default:
                    XCTFail("Expected .next")
                }
            }
        }
        
        verifiers.append(SnapshotVerifier<Int> { snapshot in
            callbackCount += 1
            switch snapshot.event {
            case .completed:
                break // expected
            default:
                XCTFail("Expected .completed")
            }
        })
        
        XCTAssertNoThrow(try verify(snapshotsOf: observable, match: verifiers))
        XCTAssertEqual(callbackCount, 5)
    }
    
    func testThatVerificationFailsIfNotEnoughVerifiers() {
        let elements = [1, 2, 3, 4]
        let observable = Observable.from(elements)
        
        XCTAssertThrowsError(try verify(snapshotsOf: observable, match: []))
    }
    
    func testThatVerificationFailsIfTooManyVerifiers() {
        let expected = 1
        let observable = Observable.just(expected)
        
        let verifier = SnapshotVerifier<Int> { _ in }

        XCTAssertThrowsError(try verify(snapshotsOf: observable, match: [verifier, verifier, verifier]))
    }
    
}
