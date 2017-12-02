import XCTest
import RxSwift

extension XCTestCase {
    
    func XCTAssert<T>(snapshotsOf observable: T, match verifiers: [SnapshotVerifier<T.E>], file: StaticString = #file, line: UInt = #line) where T: ObservableConvertibleType {
        do {
            try verify(snapshotsOf: observable, match: verifiers)
        } catch {
            XCTFail("\(error)", file: file, line: line)
        }
    }
    
    func verify<T>(snapshotsOf observable: T, match verifiers: [SnapshotVerifier<T.E>]) throws where T: ObservableConvertibleType {
        
        var remainingVerifiers = verifiers
        let nextVerifier = { () throws -> SnapshotVerifier<T.E> in
            guard !remainingVerifiers.isEmpty else {
                throw SnapshotVerifierErrors.notEnoughVerifiers
            }
            return remainingVerifiers.remove(at: 0)
        }
        
        var pendingError: Error?
        let disposable = observable.asObservable().subscribe { event in
            let snapshot = Snapshot(event: event)
            do {
                try nextVerifier().verify(snapshot)
            } catch {
                pendingError = error
            }
        }
        disposable.dispose()
        
        if let pendingError = pendingError {
            throw pendingError
        }
        
        guard remainingVerifiers.isEmpty else {
            throw SnapshotVerifierErrors.tooManyVerifiers(remainder: remainingVerifiers.count)
        }
    }
    
}
