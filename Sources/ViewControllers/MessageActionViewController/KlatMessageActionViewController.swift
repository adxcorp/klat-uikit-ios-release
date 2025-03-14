
import UIKit
import TalkPlus

class KlatMessageActionViewController: KlatBaseViewController {
    
    var chatMessage:TPMessage?
    var didDeleteButtonTapped:((TPMessage) -> Void)?
    var didEmojiButtonTapped:((TPMessage, String) -> Void)?
    
    private var viewModel = KlatMessageActionViewModel()
    
    private var isMyMessage:Bool? {
        get {
            guard let message = chatMessage else { return false }
            return viewModel.isMyMessage(message: message)
        }
    }
    
    @IBOutlet weak var actionButtonStackView: UIStackView!
    
    private var emojis:[Int:String] {
        get {
            var emojiDict:[Int:String] = [:]
            let emojis = UITableView.getSupportedEmojiList()
            var emojiKeyValue = 200
            for emoji in emojis {
                emojiDict[emojiKeyValue] = emoji
                emojiKeyValue += 1
            }
            return emojiDict
        }
    }
    
    @IBOutlet weak var copyActionView: UIView! {
        didSet {
            copyActionView.roundCorners(maskedCorners: [.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 12)
            if let imageMessage = chatMessage?.getFileUrl(), imageMessage.count > 0 {
                copyActionView.isHidden = true
            }
        }
    }
    @IBOutlet weak var deleteActionView: UIView! {
        didSet {
            deleteActionView.roundCorners(maskedCorners: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner], radius: 12)
            let isMyMessage = self.isMyMessage ?? false
            deleteActionView.isHidden = !isMyMessage
        }
    }
    
    @IBOutlet weak var rootStackView: UIStackView! {
        didSet {
            rootStackView.roundCorners(maskedCorners: [.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 12)
        }
    }
    
    @IBOutlet weak var closeButton: UIButton! {
        didSet{
            closeButton.setTitle("", for: .normal)
            closeButton.sizeToFit()
        }
    }
    
    @IBOutlet weak var copyButton: UIButton! {
        didSet{
            copyButton.setTitle("", for: .normal)
            copyButton.sizeToFit()
            copyButton.isUserInteractionEnabled = false
        }
    }
    
    @IBOutlet weak var deleteButton: UIButton! {
        didSet{
            deleteButton.setTitle("", for: .normal)
            deleteButton.isUserInteractionEnabled = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupRootView()
        setupActionViews()
        setupEmojiButtons()
        setupRoundCorner()
    }
    
    @IBAction func closeButtonClicked(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let touch = touches.first , touch.view == self.view {
            self.dismiss(animated: true)
        }
    }
    
    private func setupRoundCorner() {
        let arrangedSubviews = actionButtonStackView.arrangedSubviews.filter {
            $0.isHidden == false && $0.tag != 200
        }
        guard arrangedSubviews.count == 1 else { return }
        if let view = arrangedSubviews.first {
            let maskedCorners:CACornerMask = [
                .layerMinXMinYCorner,
                .layerMaxXMinYCorner,
                .layerMinXMaxYCorner,
                .layerMaxXMaxYCorner,
            ]
            view.roundCorners(maskedCorners: maskedCorners, radius: 12)
        }
    }
    
    private func setupRootView() {
        view.backgroundColor = UIColor.KlatBlackColors.blackColor1.withAlphaComponent(0.5)
        view.layer.cornerRadius = 10
    }
    
    private func setupActionViews() {
        let copyGesture = UITapGestureRecognizer(target: self, action: #selector(copyMessageTapped))
        copyActionView.addGestureRecognizer(copyGesture)
        let deleteGesture = UITapGestureRecognizer(target: self, action: #selector(deleteMessageTapped))
        deleteActionView.addGestureRecognizer(deleteGesture)
    }
    
    private func setupEmojiButtons() {
        for tag in 200...209 {
            if let targetView = self.view.viewWithTag(tag) as? UIImageView {
                if let image = fromEmoji(emojis[tag]!, size: 20.0) {
                    targetView.image = image
                    targetView.backgroundColor = UIColor.klatWhiteColor
                    targetView.layer.cornerRadius = 9
                    targetView.contentMode = .center
                    targetView.isUserInteractionEnabled = true
                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(emojiButtonClicked(_:)))
                    targetView.addGestureRecognizer(tapGesture)
                }
            }
        }
    }
    
    private func fromEmoji(_ emoji: String, size: CGFloat) -> UIImage? {
        let label = UILabel()
        label.text = emoji
        label.font = UIFont.systemFont(ofSize: size)
        label.sizeToFit()
        
        UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        label.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

extension KlatMessageActionViewController {
    
    @objc func copyMessageTapped() {
        if let textMessage = chatMessage?.getText() {
            UIPasteboard.general.string = textMessage
        }
        dismiss(animated: true, completion: nil)
    }
    
    @objc func deleteMessageTapped() {
        dismiss(animated: true)
        guard let message = chatMessage else { return }
        DispatchQueue.main.async { [weak self] in
            self?.didDeleteButtonTapped?(message)
        }
    }
    
    @objc func emojiButtonClicked(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true)
        guard let tappedImageView = sender.view as? UIImageView else { return }
        guard let emoji = emojis[tappedImageView.tag] else { return }
        guard let message = chatMessage else { return }
        DispatchQueue.main.async { [weak self] in
            self?.didEmojiButtonTapped?(message, emoji)
        }
    }
}
