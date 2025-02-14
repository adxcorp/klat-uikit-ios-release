
import UIKit

extension UITableViewCell {
    
    func makeEmojiStackViews(emojis:[String], reactions:[String:Any]) -> [UIStackView] {
        // init stack views
        var stackViews: [UIStackView] = []
        for _ in 0..<((emojis.count/4)+1) {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.alignment = .trailing
            stackView.distribution = .fill
            stackView.spacing = 5
            stackViews.append(stackView)
        }
        // Make Emoji View and add it to StackView
        var stackViewIndex = 0
        for emoji in emojis {
            if reactions[emoji] == nil { continue }
            if let users = reactions[emoji] as? [String] {
                let emojiView = makeEmojiView(emoji: emoji, count: users.count)
                stackViews[stackViewIndex].addArrangedSubview(emojiView)
            }
            // 4 views in a line
            if stackViews[stackViewIndex].arrangedSubviews.count == 4 {
                stackViewIndex = stackViewIndex + 1
            }
        }
        return stackViews
    }
    
    func makeEmojiView(emoji:String, count:Int) -> UIView {
        // StackView
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 4
        // Labels
        let label1 = UILabel()
        label1.text = emoji
        label1.font = .systemFont(ofSize: 14)
        let label2 = UILabel()
        label2.text = "\(count)"
        label2.font = .systemFont(ofSize: 12)
        // Add Labels to StackView
        stackView.addArrangedSubview(label1)
        stackView.addArrangedSubview(label2)
        // StackView Wrapper View
        let containerView = UIView()
        containerView.backgroundColor = .systemGray5
        containerView.layer.cornerRadius = 10
        containerView.layer.masksToBounds = true
        containerView.backgroundColor = .white
        containerView.layer.borderWidth = 1.5
        containerView.layer.borderColor = UIColor.Border.klatDefaultColor.cgColor
        containerView.addSubview(stackView)
        // Auto Layout
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 9),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -9),
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 3),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -3)
        ])
        return containerView
    }
    
}
