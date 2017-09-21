import Foundation
import UIKit

extension Array where Element == NSLayoutConstraint {
    func activateAll() {
        forEach { $0.isActive = true }
    }
}
