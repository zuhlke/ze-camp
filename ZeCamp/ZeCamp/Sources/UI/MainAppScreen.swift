import UIKit

struct MainAppScreen: Screen {
    private var scheduleScreen: Screen
    
    init(schedule: Schedule) {
        scheduleScreen = ScheduleScreen(schedule: schedule)
    }
    
    func makeViewController() -> UIViewController {
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
