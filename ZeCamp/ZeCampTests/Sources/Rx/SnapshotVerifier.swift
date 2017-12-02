import Foundation

struct SnapshotVerifier<Element> {
    private var base: (Snapshot<Element>) throws -> Void
    
    init(_ base: @escaping (Snapshot<Element>) throws -> Void) {
        self.base = base
    }
    
    func verify(_ snapshot: Snapshot<Element>) throws {
        try base(snapshot)
    }
    
}
