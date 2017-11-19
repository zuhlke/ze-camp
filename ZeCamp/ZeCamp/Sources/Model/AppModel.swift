import Foundation
import RxSwift

struct AppModel {
    
    enum Errors: Error {
        case missingScheduleFile
    }
    
    var schedule: Observable<Schedule>
    
    init(forContentsNamed content: String, in bundle : Bundle = .main) {
        schedule = Observable.create { observer in
            DispatchQueue.global(qos: .userInteractive).async {
                
                do {
                    
                    guard let scheduleUrl = bundle.url(forResource: "schedule", withExtension: "json", subdirectory: content) else {
                        throw Errors.missingScheduleFile
                    }
                    
                    let scheduleData = try Data(contentsOf: scheduleUrl)
                    
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    
                    let schedule = try decoder.decode(Schedule.self, from: scheduleData)
                    observer.onNext(schedule)
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
                
            }
            
            return Disposables.create()
        }
    }
    
}
