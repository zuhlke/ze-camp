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
        
        let vc = UIViewController()
        let indicator = UIActivityIndicatorView()
        indicator.startAnimating()
        vc.view = indicator
        
        let rootViewController = model.schedule.observeOn(MainScheduler.instance).map { scheduleLoadable -> UIViewController in
            switch scheduleLoadable {
            case .loading:
                let vc = UIViewController()
                let indicator = UIActivityIndicatorView()
                indicator.startAnimating()
                vc.view = indicator
                return vc
                
            case .loaded(let schedule):
                let scheduleScreen = ScheduleScreen(schedule: schedule)
                
                UIBarButtonItem.appearance().setTitleTextAttributes([
                    .font: UIFont(name: "AAZuehlke", size: 18)!
                    ], for: .normal)
                
                let navigation = UINavigationController(rootViewController: scheduleScreen.makeViewController())
                
                navigation.navigationBar.prefersLargeTitles = true
                navigation.navigationBar.largeTitleTextAttributes = [
                    .font: UIFont(name: "AAZuehlkeMedium", size: 28)!,
                ]
                
                navigation.navigationBar.titleTextAttributes = [
                    .font: UIFont(name: "AAZuehlkeMedium", size: 18)!,
                ]
                
                return navigation
            }
        }
        
        rootViewController.subscribe(onNext: { viewController in
            window.rootViewController = viewController
        }).disposed(by: bag)
        
        return true
    }

}

