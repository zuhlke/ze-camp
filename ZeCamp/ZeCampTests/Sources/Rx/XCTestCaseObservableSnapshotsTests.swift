import XCTest
import RxSwift
@testable import ZeCamp

class XCTestCaseObservableSnapshotsTests: XCTestCase {
    
    func testThatAVerifierIsCalledForEachEvent() {
        let elements = [1, 2, 3, 4]
        let observable = Observable.from(elements)
        
        var callbackCount = 0
        var verifiers = elements.map { expected in
            return SnapshotVerifier<Int>.next { value in
                callbackCount += 1
                XCTAssertEqual(expected, value)
            }
        }
        verifiers.append(.completed {
            callbackCount += 1
            })
        
        XCTAssertNoThrow(try verify(snapshotsOf: observable, match: verifiers))
        XCTAssertEqual(callbackCount, 5)
    }
    
    func testThatAVerifierIsCalledForEachEventForPrefix() {
        let elements = [1, 2, 3, 4]
        let observable = Observable.from(elements)
        
        var callbackCount = 0
        let verifiers = elements.map { expected in
            return SnapshotVerifier<Int>.next { value in
                callbackCount += 1
                XCTAssertEqual(expected, value)
            }
        }
        
        XCTAssertNoThrow(try verify(snapshotsOf: observable, match: verifiers, options: [.matchPrefix]))
        XCTAssertEqual(callbackCount, 4)
    }
    
    func testThatVerificationFailsIfNotEnoughVerifiers() {
        let elements = [1, 2, 3, 4]
        let observable = Observable.from(elements)
        
        XCTAssertThrowsError(try verify(snapshotsOf: observable, match: []))
    }
    
    func testThatVerificationFailsIfTooManyVerifiers() {
        let expected = 1
        let observable = Observable.just(expected)
        
        let verifier = SnapshotVerifier<Int>.any()

        XCTAssertThrowsError(try verify(snapshotsOf: observable, match: [verifier, verifier, verifier]))
    }
    
}
