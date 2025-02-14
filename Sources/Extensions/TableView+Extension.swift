
import UIKit

extension UITableView {
    
    func setEmptyView(image:UIImage?, message:String) {
        let emptyView = UIView(frame: CGRect(x: self.center.x,
                                             y: self.center.y,
                                             width: self.bounds.size.width,
                                             height: self.bounds.size.height))
        
        let messageLabel = UILabel()
        messageLabel.textColor = UIColor.lightGray
        messageLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        messageLabel.numberOfLines = 2
        messageLabel.textAlignment = .center
        messageLabel.text = message
        
        var stackView = UIStackView()
        if image != nil {
            let imageView = UIImageView(image: image)
            stackView = UIStackView(arrangedSubviews: [imageView, messageLabel])
            stackView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: 40),
                imageView.heightAnchor.constraint(equalToConstant: 40),
            ])
        } else {
            stackView = UIStackView(arrangedSubviews: [messageLabel])
            stackView.translatesAutoresizingMaskIntoConstraints = false
        }
        
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 12
        emptyView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor, constant: 0),
            stackView.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor, constant: 0),
        ])
        
        self.backgroundView = emptyView
        self.separatorStyle = .none
    }
    
    func restore() {
        self.backgroundView = nil
        //self.separatorStyle = .singleLine
    }
}

extension UITableView {
     
    static func getSupportedEmojiList() -> [String] {
        return ["😀", "👍", "✅", "😂", "♥️", "😎", "😍", "👎", "👏", "👀"]
    }

}
