import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.makeKeyAndVisible()
        self.window = window
        
        let scheduleUrl = Bundle.main.bundleURL.appendingPathComponent("Content").appendingPathComponent("schedule.json")
        
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
        
        let scheduleNavigation = scheduleScreen
            .makeViewController()
            .wrappedInUINavigationController()
        
        let scheduleImage = UIImage(named: "schedule", in: Bundle.main, compatibleWith: nil)
        scheduleNavigation.tabBarItem = UITabBarItem(title: "Schedule", image: scheduleImage, selectedImage: scheduleImage)
        
        let infoController = InfoScreen().makeViewController()
        let info = UIImage(named: "info", in: Bundle.main, compatibleWith: nil)

        infoController.tabBarItem = UITabBarItem(title: "Info", image: info, selectedImage: info)
        
        
        var foregroundColor = UIColor.blue
        if #available(iOS 11.0, *) {
            foregroundColor = UIColor(named: "teal") ?? foregroundColor
        }
        
        let tabBar = UITabBarController()
        tabBar.viewControllers = [scheduleNavigation, infoController]
        window.rootViewController = tabBar
        window.tintColor = foregroundColor
        
        
        return true
    }

}

