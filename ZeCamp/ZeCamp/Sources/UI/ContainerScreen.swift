import UIKit
import RxSwift

struct ContainerScreen: Screen {
    var content: Observable<Screen>
    
    func makeViewController() -> UIViewController {
        return ViewController(content: content)
    }
    
    private class ViewController: UIViewController {
        private let bag = DisposeBag()
        private let content: Observable<Screen>
        
        init(content: Observable<Screen>) {
            self.content = content
            super.init(nibName: nil, bundle: nil)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            view.backgroundColor = .white
            navigationItem.largeTitleDisplayMode = .never
            
            var previous: UIViewController?
            content.subscribe(onNext: { [weak self] screen in
                guard let s = self else { return }
                let viewController = screen.makeViewController()
                previous?.willMove(toParentViewController: nil)
                previous?.view.removeFromSuperview()
                previous?.removeFromParentViewController()
                
                previous = viewController
                
                viewController.willMove(toParentViewController: s)
                s.title = viewController.title
                s.view.addFillingSubview(viewController.view)
                s.addChildViewController(viewController)
            }).disposed(by: bag)
        }
    }
}

