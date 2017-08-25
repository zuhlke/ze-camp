import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        NSLog("Starting ZeCamp, git commit: " + Bundle.main.gitVersionString!)
        
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
        window.rootViewController = scheduleScreen.makeViewController()
        
        return true
    }

}

