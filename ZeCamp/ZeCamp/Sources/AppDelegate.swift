import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.makeKeyAndVisible()
        self.window = window
        
        let schedule = JsonReader.getJson(FileName: "schedule.json", type: Schedule.self)
        
        let scheduleScreen = ScheduleScreen(schedule: schedule)
        
        UIBarButtonItem.appearance().setTitleTextAttributes([
            .font: UIFont(name: "AAZuehlke", size: 18)!
            ], for: .normal)
        
        let navigation = UINavigationController(rootViewController: scheduleScreen.makeViewController())
        
        var foregroundColor = UIColor.blue
        if #available(iOS 11.0, *) {
            foregroundColor = UIColor(named: "teal") ?? foregroundColor
            navigation.navigationBar.prefersLargeTitles = true
            navigation.navigationBar.largeTitleTextAttributes = [
                .font: UIFont(name: "AAZuehlkeMedium", size: 28)!,
            ]
        }
        
        navigation.navigationBar.titleTextAttributes = [
            .font: UIFont(name: "AAZuehlkeMedium", size: 18)!,
        ]
        window.rootViewController = navigation
        window.tintColor = foregroundColor
        
        
        return true
    }

}

