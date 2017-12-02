import Foundation
import RxSwift

enum SnapshotVerifierErrors: Error, CustomStringConvertible {
    enum EventKind {
        case next
        case completed
        case error
    }
    
    case notEnoughVerifiers
    case tooManyVerifiers(remainder: Int)
    case eventKindMismatch(expected: EventKind, actual: EventKind)
    
    var description: String {
        switch self {
        case .notEnoughVerifiers:
            return "Observable produced more events than there are verifiers."
        case .tooManyVerifiers(let remainder):
            return "Observable terminated early. Remaining verifiers count: \(remainder)."
        case .eventKindMismatch(let expected, let actual):
            return "Expected \(expected), recevied \(actual)."
        }
    }
}

extension Event {
    var kind: SnapshotVerifierErrors.EventKind {
        switch self {
        case .next(_):
            return .next
        case .completed:
            return .completed
        case .error:
            return .error
        }
    }
}
