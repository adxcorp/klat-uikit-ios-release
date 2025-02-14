
import UIKit
import TalkPlus

class KlatEditChannelViewController: KlatBaseViewController {

    var channel:TPChannel?
    
    private var viewModel:KlatEditChannelViewModel!
    
    private var isChannelImageUpdated = false
    
    @IBOutlet weak var channelNameCountLabel: UILabel! {
        didSet {
            channelNameCountLabel.textColor = .lightGray
        }
    }
    @IBOutlet weak var channelImageView: UIImageView! {
        didSet {
            channelImageView.layer.cornerRadius = channelImageView.frame.height / 2
            channelImageView.layer.borderWidth = 1
            channelImageView.layer.borderColor = UIColor.Background.layerGrayColor2.cgColor
            channelImageView.clipsToBounds = true
            channelImageView.isUserInteractionEnabled = true
        }
    }
    @IBOutlet weak var addImageView: UIImageView! {
        didSet {
            let image = UIImage(named: "KlatCameraWithPlus", in: Bundle(for: type(of: self)), compatibleWith:nil)
            addImageView.image = image
        }
    }
    @IBOutlet weak var channelNameTextField: KlatCustomTextField! {
        didSet {
            channelNameTextField.backgroundColor = UIColor.Background.textFieldColor
            channelNameTextField.layer.cornerRadius = 10
            channelNameTextField.delegate = self
        }
    }
    @IBOutlet weak var saveButton: UIButton! {
        didSet {
            saveButton.layer.cornerRadius = 10
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupNavigationItem()
        setupChatChannelInfo()
        setupGestureRecognizer()
        setupChannelImageView()
        setupViewModel()
    }
    
    private func setupViewModel() {
        viewModel = KlatEditChannelViewModel(targetChannel: self.channel)
        viewModel.didChannelUpdated = { [weak self] channel in
            guard let self = self else { return }
            closeButtonTapped()
        }
    }
    
    private func setupChannelImageView() {
        channelImageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(channelImageClicked))
        channelImageView.addGestureRecognizer(tapGesture)
        let image = UIImage(named: "KlatDefaultChannelImageWithCamera", in: Bundle(for: type(of: self)), compatibleWith:nil)
        channelImageView.image = image
        addImageView.isHidden = true
        guard let imageUrlString = channel?.getImageUrl(), imageUrlString.count > 0 else { return }
        UIImage.loadImage(from: imageUrlString) { [weak self] image, _ in
            self?.channelImageView.image = image
            self?.addImageView.isHidden = false
        }
    }
    
    private func setupGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    private func setupChatChannelInfo() {
        guard let channel = self.channel else { return }
        let channelName = channel.getName()
        channelNameTextField.text = channelName
        channelNameCountLabel.text = "\(channelName?.count ?? 0)/30"
        if let imageUrl = channel.getImageUrl(), imageUrl.count > 0 {
            UIImage.loadImage(from: imageUrl) { [weak self] image, _ in
                guard let image = image else { return }
                self?.channelImageView.image = image
            }
            return
        }
        self.channelImageView.image = UIImage()
    }

    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let channelName = channelNameTextField.text, channelName.count > 0 else { return }
        let channelImage = isChannelImageUpdated ? channelImageView.image : nil
        updateChatChannel(channelName: channelName, image: channelImage)
    }
    
    func updateChatChannel(channelName:String, image:UIImage?) {
        Task {
            do {
                let screenSize = UIScreen.main.bounds.size
                let resizedImage = viewModel.resizeImageToFit(screenSize: screenSize, image: image)
                try await viewModel.updateChatChannel(channelName: channelName, image: resizedImage)
            } catch {
                showKlatToast("\(error.localizedDescription)")
            }
        }
    }
    
    private func setupNavigationItem() {
        navigationItem.title = "채널 정보 변경"
        navigationItem.hidesBackButton = true
        navigationItem.rightBarButtonItem = rightBarButton
        if let navigationBar = navigationController?.navigationBar {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.backgroundColor = .clear
            appearance.shadowColor = nil
            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
        }
    }
    
    private lazy var rightBarButton: UIBarButtonItem = {
        // Clsose Button
        let backButton = UIButton()
        backButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        let backImage = UIImage(named: "KlatXMark", in: Bundle(for: type(of: self)), compatibleWith:nil)
        backButton.setImage(backImage, for: .normal)
        backButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        // BarButtonItem
        let barButtonItem = UIBarButtonItem(customView: backButton)
        barButtonItem.tintColor = .black
        return barButtonItem
    }()
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let touch = touches.first , touch.view == self.view {
            self.resignFirstResponder()
        }
    }
}

extension KlatEditChannelViewController {
    
    @objc func channelImageClicked() {
        showActionSheetForAlbumOrCamera()
    }
    
    @objc private func closeButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func dismissKeyboard() {
        channelNameTextField.resignFirstResponder()
    }
}

extension KlatEditChannelViewController : UITextFieldDelegate {
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool
    {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        channelNameCountLabel.text = "\(updatedText.count)/30"
        let result = updatedText.count <= 30
        saveButton.isEnabled = true
        if updatedText.count == 0 {
            saveButton.isEnabled = false
        }
        return result
    }
}

extension KlatEditChannelViewController {
    
    override public func imagePickerController(_ picker: UIImagePickerController,
                                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var image:UIImage?
        if let editedImage = info[.editedImage] as? UIImage {
            image = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            image = originalImage
        }
        
        if let channelImage = image {
            channelImageView.image = channelImage
            channelImageView.layer.cornerRadius = channelImageView.frame.width / 2
            channelImageView.contentMode = .scaleToFill
            isChannelImageUpdated = true
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
}
