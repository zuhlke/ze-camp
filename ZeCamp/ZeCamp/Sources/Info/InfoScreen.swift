import Foundation
import UIKit

struct InfoScreen {
    func makeViewController() -> UIViewController {
        let viewController = UIViewController()
        viewController.title = "Information"
        
        let view = viewController.view!
        
        view.backgroundColor = .white
        
        let navigation = UINavigationController(rootViewController: viewController)
        
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
        

        
        return navigation
    }
}
