import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.makeKeyAndVisible()
        self.window = window
        window.rootViewController = UIViewController()
        
        let scheduleUrl = Bundle.main.bundleURL.appendingPathComponent("MyResources").appendingPathComponent("schedule.json")
        
        guard let scheduleData = try? Data(contentsOf: scheduleUrl) else {
            return true
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let schedule = try! decoder.decode(Schedule.self, from: scheduleData)
        
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
                .foregroundColor: foregroundColor,
                .font: UIFont(name: "AAZuehlkeMedium", size: 28)!,
            ]
        }
        
        navigation.navigationBar.titleTextAttributes = [
            .foregroundColor: foregroundColor,
            .font: UIFont(name: "AAZuehlkeMedium", size: 18)!,
        ]
        window.rootViewController = navigation
        window.tintColor = foregroundColor
        
        
        return true
    }

}

