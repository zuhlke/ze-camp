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
        window.rootViewController = vc
        
        model.schedule.observeOn(MainScheduler.instance).subscribe(onNext: { schedule in
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
            
            window.rootViewController = navigation
        }).disposed(by: bag)
        
        return true
    }

}

