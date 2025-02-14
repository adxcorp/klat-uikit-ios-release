
import UIKit

extension UIViewController {
    
    func dismissAllPresentedViewControllers(animated: Bool, completion: (() -> Void)? = nil) {
        if let presented = self.presentedViewController {
            if let navigationController = presented as? UINavigationController {
                navigationController.topViewController?.dismissAllPresentedViewControllers(animated: false) {
                    navigationController.dismiss(animated: animated, completion: completion)
                }
            } else {
                presented.dismissAllPresentedViewControllers(animated: false) {
                    presented.dismiss(animated: animated, completion: completion)
                }
            }
        } else {
            completion?()
        }
    }
    
    func showKlatToast(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.view.alpha = 0.6
        alert.view.layer.cornerRadius = 10
            
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
            alert.dismiss(animated: true)
        }
    }
    
}
