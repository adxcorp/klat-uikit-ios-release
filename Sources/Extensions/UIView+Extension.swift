
import UIKit

extension UIView {
    
    func roundCorners(maskedCorners: CACornerMask, radius: CGFloat) {
        clipsToBounds = true
        layer.cornerRadius = radius
        layer.maskedCorners = maskedCorners
    }
    
}
