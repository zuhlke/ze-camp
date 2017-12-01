import UIKit

struct AppLoadingScreen: Screen {
    
    func makeViewController() -> UIViewController {
        let vc = UIViewController()
        let indicator = UIActivityIndicatorView()
        indicator.startAnimating()
        vc.view = indicator
        return vc
    }
    
}
