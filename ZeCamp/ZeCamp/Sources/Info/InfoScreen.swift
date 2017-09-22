import Foundation
import UIKit

struct InfoScreen {
    func makeViewController() -> UIViewController {
        let viewController = UIViewController()
        viewController.title = "Information"
        
        let view = viewController.view!
        
        view.backgroundColor = .white
        
        return viewController.wrappedInUINavigationController()
    }
}
