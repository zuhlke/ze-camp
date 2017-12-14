import Foundation
import RxSwift

private enum Action<E> {
    case next(E)
    case timedOut
}

private enum State<E> {
    case waiting
    case waitingTimedOut
    case buffered(E)
    case forward(E)
    
    func reduced(with action: Action<E>, isAnticipated: @escaping (E) -> Bool) -> State<E> {
        switch action {
        case .timedOut:
            switch self {
            case .buffered(let value):
                return .forward(value)
                
            case .forward(_), .waiting, .waitingTimedOut:
                return .waitingTimedOut
            }
            
        case .next(let value):
            switch self {
            case .forward(_), .waitingTimedOut:
                return .forward(value)
            case .buffered(_), .waiting:
                return isAnticipated(value) ? .forward(value) : .buffered(value)
            }
        }
    }
}

private struct ScanInfo<E> {
    var buffered: E?
    var events: [Event<E>]
    
    func reduce(with event: Event<State<E>>) -> ScanInfo<E> {
        switch event {
        case .next(let state):
            switch state {
            case .buffered(let value):
                return ScanInfo(buffered: value, events: [])
            case .waiting, .waitingTimedOut:
                return ScanInfo(buffered: nil, events: [])
            case .forward(let value):
                return ScanInfo(buffered: nil, events: [.next(value)])
            }
        case .error(let error):
            if let buffered = buffered {
                return ScanInfo(buffered: nil, events: [.next(buffered), .error(error)])
            } else {
                return ScanInfo(buffered: nil, events: [.error(error)])
            }
        case .completed:
            if let buffered = buffered {
                return ScanInfo(buffered: nil, events: [.next(buffered), .completed])
            } else {
                return ScanInfo(buffered: nil, events: [.completed])
            }
        }
    }
}

extension ObservableType {
    
    func anticipateImminentValue(where isAnticipated: @escaping (E) -> Bool = { _ in true}) -> Observable<E> {
        return Observable.create { observer in
            let timedOutSubject = ReplaySubject<Void>.create(bufferSize: 1)
            
            let sema = DispatchSemaphore(value: 0)
            defer {
                let waitResult = sema.wait(timeout: .now() + .milliseconds(30))
                
                if waitResult == .timedOut {
                    timedOutSubject.onNext(())
                    timedOutSubject.onCompleted()
                }
            }
            
            let timedOutEvents = timedOutSubject.map { _ in Action<E>.timedOut }
            let nextEvents = self.debug("seelf").map { Action.next($0) }
            
            let events = Observable.of(timedOutEvents, nextEvents).merge().debug()
            
            var currentState = State<E>.waiting
            var scanInfo = ScanInfo<E>(buffered: nil, events: [])
            
            return events.materialize().debug().subscribe(onNext: { event in
                let sss = event.map { action -> State<E> in
                    currentState = currentState.reduced(with: action, isAnticipated: isAnticipated)
                    print("state", currentState)
                    return currentState
                }
                scanInfo = scanInfo.reduce(with: sss)
                print("scanInfo", scanInfo)

                if !scanInfo.events.isEmpty {
                    sema.signal()
                }
//                DispatchQueue.global().async {
                    scanInfo.events.forEach(observer.on)
//                }
            })
        }
    }
    
//    func anticipateImminentValue(where isAnticipated: @escaping (E) -> Bool = { _ in true}) -> Observable<E> {
//        let newObservable = Observable<E>.create { observer in
//            let sema = DispatchSemaphore(value: 0)
//
//            var stillWaiting = true
//            var bufferedValue: E?
//
//            let queue = DispatchQueue(label: "wait")
//
//            let disposable = self.subscribe { event in
//
//                queue.async {
//                    guard stillWaiting else {
//                        observer.on(event)
//                        return
//                    }
//
//                    if case .next(let value) = event, !isAnticipated(value) {
//                        bufferedValue = value
//                    } else {
//                        if let bufferedValue = bufferedValue {
//                            switch event {
//                            case .next(_), .error(_):
//                                break
//                            case .completed:
//                                observer.onNext(bufferedValue)
//                            }
//                        }
//                        observer.on(event)
//                        sema.signal()
//                    }
//                }
//
//            }
//
//            let waitResult = sema.wait(timeout: .now() + .milliseconds(30))
//
//            queue.async {
//                switch waitResult {
//                case .timedOut:
//                    if let bufferedValue = bufferedValue {
//                        observer.onNext(bufferedValue)
//                    }
//                case .success:
//                    break
//                }
//                bufferedValue = nil
//                stillWaiting = false
//            }
//
//            return disposable
//        }
//
//        return newObservable
//    }
}
