
import UIKit
import TalkPlus

class KlatMyChatMessageCell: UITableViewCell, KlatChatMessageProtocol {
    
    private var unreadCount:Int32 = 0
    
    weak private var chatMessage:TPMessage?
    
    var didImageViewTapped:((TPMessage?)->Void)?
    
    @IBOutlet weak var chatMessageContainer: UIStackView! {
        didSet {
            chatMessageContainer.backgroundColor = UIColor.Background.containerColor2
            let gesture = UITapGestureRecognizer(target: self, action: #selector(chatMessageTapped))
            chatMessageContainer.addGestureRecognizer(gesture)
            chatMessageContainer.isUserInteractionEnabled = false
        }
    }
    @IBOutlet weak var chatMessageLabel: UILabel! {
        didSet {
            chatMessageLabel.numberOfLines = 0
            chatMessageLabel.textColor = UIColor.Label.klatTextWhiteColor
        }
    }
    @IBOutlet weak var imageMessageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel! {
        didSet {
            timeLabel.numberOfLines = 1
            timeLabel.adjustsFontSizeToFitWidth = true
            timeLabel.minimumScaleFactor = 0.9
        }
    }
    @IBOutlet weak var unreadCountLabel: UILabel!
    
    @IBOutlet weak var reactionRootStackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        contentView.autoresizingMask = .flexibleHeight
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageMessageView.image = nil
        chatMessageContainer.backgroundColor = UIColor.Background.containerColor2
    }
    
    func configure(channel:TPChannel,
                   message:TPMessage,
                   otherMessages:(TPMessage?, TPMessage?),
                   tableView: UITableView,
                   indexPath:IndexPath)
    {
        chatMessage = message
        setChatTextLabel(message: message)
        setFileMessage(message: message, tableView: tableView, indexPath: indexPath)
        setTimeLabel(message: message, otherMessages: otherMessages)
        setUnreadCountLabel(channel: channel, message: message)
        setupMessageReaction(message: message)
    }
    
    @objc private func chatMessageTapped() {
        guard chatMessage?.getFileUrl().count ?? 0 > 0 else { return }
        didImageViewTapped?(chatMessage)
    }
}

extension KlatMyChatMessageCell {
    
    private func setupMessageReaction(message:TPMessage) {
        guard let reactions = message.getReactions() as? [String:Any] else { return }
        // Remove all subviews from StackView
        reactionRootStackView.arrangedSubviews.forEach { subview in
            reactionRootStackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
        let emojis = UITableView.getSupportedEmojiList()
        let stackViews = makeEmojiStackViews(emojis:emojis, reactions: reactions)
        for stackView in stackViews {
            if stackView.arrangedSubviews.count <= 0 { continue }
            reactionRootStackView.addArrangedSubview(stackView)
        }
    }
    
    private func setFileMessage(message:TPMessage, tableView: UITableView, indexPath:IndexPath) {
        let imageUrl = message.getFileUrl() ?? ""
        chatMessageContainer.layoutMargins = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        
        guard imageUrl.count > 0 else {
            imageMessageView.isHidden = true
            imageMessageView.image = nil
            return
        }
        
        chatMessageContainer.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        imageMessageView.isHidden = false
        imageMessageView.contentMode = .scaleAspectFill
        UIImage.loadImage(from: imageUrl) { [weak self] image, _ in
            guard let image = image, let self = self else { return }
            if let currentCell = tableView.cellForRow(at: indexPath) as? Self {
                chatMessageContainer.backgroundColor = .clear
                currentCell.imageMessageView.image = image
                currentCell.imageMessageView.layer.cornerRadius = 8
                currentCell.imageMessageView.clipsToBounds = true
                chatMessageContainer.isUserInteractionEnabled = true
                layoutIfNeeded()
            }
        }
    }
        
    private func setChatTextLabel(message:TPMessage) {
        chatMessageLabel.text = message.getText() ?? ""
        chatMessageLabel.isHidden = false
        if let imageUrl = message.getFileUrl(), imageUrl.count > 0 {
            chatMessageLabel.isHidden = true
        }
    }
        
    private func setTimeLabel(message:TPMessage, otherMessages:(TPMessage?, TPMessage?)) {
        
        let time = timeStringFrom(message: message)
        timeLabel.text = time
        
        timeLabel.isHidden = false
        let previousMessage = otherMessages.0
        let nextMessage = otherMessages.1
        if previousMessage == nil || nextMessage == nil {
            return
        }
        
        if message.getUserId() == nextMessage?.getUserId() {
            let nextMessageTime = timeStringFrom(message: nextMessage!)
            timeLabel.isHidden = time == nextMessageTime
        }
    }
    
    private func timeStringFrom(message:TPMessage) -> String {
        let date = Date(milliseconds: message.getCreatedAt())
        return date.toFormat("HH:mm")
    }
    
    private func setUnreadCountLabel(channel:TPChannel, message:TPMessage) {
        unreadCount = channel.getMessageUnreadCount(message)
        unreadCountLabel.text = "\(unreadCount)"
        unreadCountLabel.isHidden = unreadCount <= 0
    }
    
    func updateUnreadCountLabel(channel:TPChannel, message:TPMessage) {
        let updatedCount = channel.getMessageUnreadCount(message)
        guard self.unreadCount != updatedCount else { return }
        setUnreadCountLabel(channel: channel, message: message)
    }
    
}
