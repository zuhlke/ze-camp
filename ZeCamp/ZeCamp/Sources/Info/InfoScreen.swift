import Foundation
import UIKit

struct InfoScreen {
    func makeViewController() -> UIViewController {
        let viewController = UIViewController()
        viewController.title = "Information"
        
        let view = viewController.view!
        
        view.backgroundColor = .white
        
        let label = UILabel()
        label.text = "ZeCamp commit \(Bundle.main.shortCommitId!). © 2017 Zuhlke Engineering Ltd. ✨"
        label.numberOfLines = 0
        label.textColor = UIColor.gray
        label.font = UIFont.systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.lineBreakMode = .byWordWrapping
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(label)
        stackView.layoutMargins = UIEdgeInsets(top: 15, left: 0, bottom: 8, right: 0)
        stackView.isLayoutMarginsRelativeArrangement = true
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addFillingSubview(stackView)

        view.addFillingSubview(scrollView)
        [stackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
         stackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
         ].activateAll()

        
        
        return viewController.wrappedInUINavigationController()
    }
}
