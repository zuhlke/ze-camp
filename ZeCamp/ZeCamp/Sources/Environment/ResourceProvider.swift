import Foundation
import RxSwift

struct ResourceIdentifier {
    var name: String
    var `extension`: String
}

struct ResourceProvider {
    
    enum Errors: Error {
        case missingResource(identifier: ResourceIdentifier)
    }
    
    private static let queue = DispatchQueue(label: "Resource IO")
    
    private var folder: String
    private var bundle: Bundle
    
    init(folder: String, in bundle: Bundle = .main) {
        self.folder = folder
        self.bundle = bundle
    }
    
    func load(contentsOf identifier: ResourceIdentifier) -> Observable<Data> {
        return Observable.create { observer in
            do {
                guard let scheduleUrl = self.bundle.url(forResource: identifier.name, withExtension: identifier.extension, subdirectory: self.folder) else {
                    throw Errors.missingResource(identifier: identifier)
                }
                
                observer.onNext(try Data(contentsOf: scheduleUrl))
                observer.onCompleted()
            } catch {
                observer.onError(error)
            }
            
            return Disposables.create()
        }
    }
    
}
