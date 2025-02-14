import UIKit
import TalkPlus

class KlatChannelListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var channelNameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var memberCountLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var pushStatusImage: UIImageView!
    @IBOutlet weak var channelImage: UIImageView!
    @IBOutlet weak var messageCountUnreadLabel: UILabel! {
        didSet {
            messageCountUnreadLabel.adjustsFontSizeToFitWidth = true
            messageCountUnreadLabel.minimumScaleFactor = 0.9
        }
    }
    @IBOutlet weak var messageCountUnreadContainer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupColors()
    }
    
    private func setupColors() {
        channelNameLabel.textColor = UIColor.Label.klatDefaultColor
        lastMessageLabel.textColor = UIColor.Label.klatTextGrayColor1
        memberCountLabel.textColor = UIColor.Label.klatTextGrayColor1
        timeLabel.textColor = UIColor.Label.klatTextGrayColor1
        messageCountUnreadLabel.textColor = UIColor.Label.klatTextWhiteColor
        messageCountUnreadContainer.tintColor = UIColor.UIView.klatDefaultColor
        messageCountUnreadContainer.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(chatChannel:TPChannel, tableView: UITableView, indexPath:IndexPath) {
        channelNameLabel.text = chatChannel.getName()
        memberCountLabel.text = "\(chatChannel.getMemberCount())"
        lastMessageLabel.text = chatChannel.getLastMessage()?.getText() ?? ""
        
        messageCountUnreadContainer.isHidden = true
        messageCountUnreadContainer.backgroundColor = .clear
        messageCountUnreadLabel.text = ""
        if chatChannel.getUnreadCount() > 0 {
            messageCountUnreadContainer.isHidden = false
            messageCountUnreadContainer.backgroundColor = UIColor.Background.klatDefaultColor
            messageCountUnreadLabel.text = "\(chatChannel.getUnreadCount())"
            if chatChannel.getUnreadCount() > 999 {
                messageCountUnreadLabel.text = "999+"
            }
        }
        
        if let time = chatChannel.getLastMessage()?.getCreatedAt() {
            let date = Date(milliseconds: time)
            timeLabel.text = date.toFormat("HH:mm")
            if Date().isSameDay(as: date) == false {
                let formatter = DateFormatter()
                formatter.dateFormat = "MM월dd일"
                let formattedToday = formatter.string(from: date)
                timeLabel.text = formattedToday
            }
        } else {
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "MM월dd일"
            let formattedToday = formatter.string(from: date)
            timeLabel.text = formattedToday
        }
        
        let pushImageName = chatChannel.isPushNotificationDisabled() ? "KlatPushDisable" : "KlatPushEnable"
        let pushImage = UIImage(named: pushImageName, in: Bundle(for: type(of: self)), compatibleWith:nil)!
        setImage(imageView: pushStatusImage, image: pushImage)
        
        let defaultImage = UIImage(named: "KlatDefaultChannelImage", in: Bundle(for: type(of: self)), compatibleWith:nil)!
        
        channelImage.contentMode = .scaleAspectFit
        channelImage.layer.cornerRadius = channelImage.frame.width / 2
        
        guard let imageUrl = chatChannel.getImageUrl(), imageUrl.count > 0 else {
            setImage(imageView: channelImage, image: defaultImage)
            return
        }
        
        UIImage.loadImage(from: imageUrl) { [weak self] image, _ in
            guard let image = image else {
                self?.setImage(imageView: self?.channelImage, image: defaultImage)
                return
            }
            if let currentCell = tableView.cellForRow(at: indexPath) as? KlatChannelListTableViewCell {
                currentCell.clipsToBounds = true
                self?.setImage(imageView: currentCell.channelImage, image: image)
            }
        }
    }
    
    private func setImage(imageView:UIImageView?, image:UIImage?) {
        guard let imageView = imageView, let image = image else { return }
        UIView.performWithoutAnimation {
            imageView.image = image
        }
    }
    
    func changeKeywordColorInChannelName(keyword:String, color:UIColor = UIColor.init(klatHexCode: "#00BFBF")) {
        guard let channelName = channelNameLabel.text, keyword.count > 0 else { return }
        channelNameLabel.attributedText = getAttributedString(originalText: channelName, targetText: keyword, color: color)
    }
    
    private func getAttributedString(originalText:String, targetText:String, color:UIColor) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: originalText)
        if let range = originalText.lowercased().range(of: targetText.lowercased()) {
            let nsRange = NSRange(range, in: originalText)
            attributedString.addAttribute(.foregroundColor, value: color, range: nsRange)
        }
        return attributedString
    }
    
    private func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async { completion(image) }
            } else {
                DispatchQueue.main.async { completion(nil) }
            }
        }
    }
    
}

