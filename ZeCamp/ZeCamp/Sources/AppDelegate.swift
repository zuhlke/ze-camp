import UIKit
import RxSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    private let bag = DisposeBag()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.makeKeyAndVisible()
        self.window = window
        
        window.tintColor = UIColor(named: "teal")
        
        let resourceProvider = ResourceProvider(folder: "Content")
        let model = AppModel(resourceProvider: resourceProvider)
        
        let rootScreen = model.schedule
            .map { scheduleLoadable -> Screen in
                switch scheduleLoadable {
                case .loaded(let schedule):
                    return MainAppScreen(schedule: schedule)
                case .loading:
                    return AppLoadingScreen()
                }
        }
        
        rootScreen
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { screen in
                window.rootViewController = screen.makeViewController()
            })
            .disposed(by: bag)
        
        return true
    }

}

