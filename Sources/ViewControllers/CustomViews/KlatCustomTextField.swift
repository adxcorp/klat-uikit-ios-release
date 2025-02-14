
import UIKit

class KlatCustomTextField: UITextField {

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return adjustedBounds(bounds)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return adjustedBounds(bounds)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return adjustedBounds(bounds)
    }
    
    private func adjustedBounds(_ bounds: CGRect) -> CGRect {
        let leftPadding: CGFloat = 10
        let rightPadding: CGFloat = 55
        return bounds.inset(by: UIEdgeInsets(top: 0, left: leftPadding, bottom: 0, right: rightPadding))
    }
}
