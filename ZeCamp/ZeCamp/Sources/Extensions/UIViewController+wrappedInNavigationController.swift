import Foundation
import UIKit

extension UIViewController {
    func wrappedInUINavigationController() -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: self)
        
        if #available(iOS 11.0, *) {
            navigationController.navigationBar.prefersLargeTitles = true
            navigationController.navigationBar.largeTitleTextAttributes = [
                .font: UIFont(name: "AAZuehlkeMedium", size: 28)!,
            ]
        }
        
        navigationController.navigationBar.titleTextAttributes = [
            .font: UIFont(name: "AAZuehlkeMedium", size: 18)!,
        ]

        return navigationController
    }
}
