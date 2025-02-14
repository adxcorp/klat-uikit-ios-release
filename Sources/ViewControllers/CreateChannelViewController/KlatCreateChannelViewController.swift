
import UIKit
import TalkPlus

class KlatCreateChannelViewController: KlatBaseViewController {
    
    var newChatChannelCreated:((TPChannel)->Void)?
    
    private let viewModel = KlatCreateChannelViewModel()
    
    private var isChannelImageUpdated = false
    
    private enum KlatTextFieldTag: Int {
        case maxMemberCount
        case channelNameCount
    }
    
    @IBOutlet weak var stepperMinusButton: UIButton! {
        didSet {
            let image = UIImage(named: "KlatStepperMinus", in: Bundle(for: type(of: self)), compatibleWith:nil)
            stepperMinusButton.setTitle("", for: .normal)
            stepperMinusButton.setImage(image, for: .normal)
        }
    }
    @IBOutlet weak var stepperPlusButton: UIButton! {
        didSet {
            let image = UIImage(named: "KlatStepperPlus", in: Bundle(for: type(of: self)), compatibleWith:nil)
            stepperPlusButton.setTitle("", for: .normal)
            stepperPlusButton.setImage(image, for: .normal)
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var channelImage: UIImageView!
    @IBOutlet weak var createChannelButton: UIButton! {
        didSet {
            createChannelButton.backgroundColor = UIColor.Background.buttonColor
            createChannelButton.tintColor = UIColor.Button.klatDefaultColor
        }
    }
    @IBOutlet weak var channelNameTextField: KlatCustomTextField! {
        didSet {
            channelNameTextField.backgroundColor = UIColor.Background.textFieldColor
            channelNameTextField.tag = KlatTextFieldTag.channelNameCount.rawValue
            channelNameTextField.delegate = self
        }
    }
    @IBOutlet weak var channelNameCountLabel: UILabel! {
        didSet {
            channelNameCountLabel.textColor = .lightGray
        }
    }
    @IBOutlet weak var maxMemberCountTextField: UITextField! {
        didSet {
            maxMemberCountTextField.backgroundColor = UIColor.Background.textFieldColor
            maxMemberCountTextField.keyboardType = .numberPad
            maxMemberCountTextField.delegate = self
            maxMemberCountTextField.tag = KlatTextFieldTag.maxMemberCount.rawValue
        }
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupNavigationItem()
        setupDefaultChannelImageView()
        setupChannelNameCountLabel()
        setupRootView()
    }
    
    private func setupChannelNameCountLabel() {
        channelNameCountLabel.text = "0/30"
    }
    
    private func setupRootView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupNavigationItem() {
        navigationItem.title = "채널 생성"
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    private func setupDefaultChannelImageView() {
        let image = UIImage(named: "KlatDefaultChannelImageWithCamera", in: Bundle(for: type(of: self)), compatibleWith:nil)
        channelImage.image = image
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(channelImageClicked))
        channelImage.isUserInteractionEnabled = true
        channelImage.addGestureRecognizer(tapGesture)
    }
    
    private lazy var rightBarButton: UIBarButtonItem = {
        // Clsose Button
        let backButton = UIButton()
        backButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        let backImage = UIImage(named: "KlatXMark", in: Bundle(for: type(of: self)), compatibleWith:nil)
        backButton.setImage(backImage, for: .normal)
        backButton.addTarget(self, action: #selector(closeButtonClicked), for: .touchUpInside)
        // BarButtonItem
        let barButtonItem = UIBarButtonItem(customView: backButton)
        barButtonItem.tintColor = .black
        return barButtonItem
    }()
    
    @IBAction func stepperMinusTapped(_ sender: Any) {
        let currentText = maxMemberCountTextField.text ?? ""
        guard var intNumber = Int(currentText), intNumber > 1 else { return }
        intNumber = intNumber - 1
        maxMemberCountTextField.text = String(intNumber)
    }
    
    @IBAction func stepperPlusTapped(_ sender: Any) {
        let currentText = maxMemberCountTextField.text ?? ""
        guard var intNumber = Int(currentText), intNumber < 100 else { return }
        intNumber = intNumber + 1
        maxMemberCountTextField.text = String(intNumber)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
        
        let currentText = maxMemberCountTextField.text ?? ""
        guard currentText.isEmpty == false else {
            maxMemberCountTextField.text = String(100)
            return
        }
        
        if Int(currentText) ?? 0 > 100 {
            maxMemberCountTextField.text = String(100)
            return
        }
        
        if Int(currentText) ?? 0 < 1 {
            maxMemberCountTextField.text = String(1)
            return
        }
    }
        
    @objc func closeButtonClicked() {
        self.presentingViewController?.dismiss(animated: true)
    }
    
    @objc func channelImageClicked() {
        showActionSheetForAlbumOrCamera()
    }
    
    @IBAction func createNewChannelClicked(_ sender: Any) {
        guard validationForNewChannel() else { return }
        let channelImage = isChannelImageUpdated ? channelImage.image : nil
        createNewChatChannel(channelName: channelNameTextField.text!,
                                       maxMemberCount: Int(maxMemberCountTextField.text!)!,
                                       image: channelImage)
    }
    
    private func createNewChatChannel(channelName:String,
                                      maxMemberCount:Int,
                                      image:UIImage?)
    {
        Task {
            do {
                try await viewModel.createNewChatChannel(channelName: channelName,
                                                         maxMemberCount: maxMemberCount,
                                                         image: image) { [weak self] channel in
                    guard let self = self else { return }
                    guard let chatChannel = channel else {
                        self.presentingViewController?.dismiss(animated: true)
                        return
                    }
                    self.presentingViewController?.dismiss(animated: true)
                    newChatChannelCreated?(chatChannel)
                }
            } catch {
                showKlatToast("\(error.localizedDescription)")
            }
        }
    }
    
    private func validationForNewChannel() -> Bool {
        // Max Channel Name Length
        var currentText = channelNameTextField.text ?? ""
        var updatedText = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
        var truncatedString = String(updatedText.prefix(30))
        channelNameTextField.text = truncatedString
        guard channelNameTextField.text?.isEmpty == false else {
            channelNameTextField.becomeFirstResponder()
            return false
        }
        // Max count to join a channel
        currentText = maxMemberCountTextField.text ?? ""
        updatedText = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
        truncatedString = String(updatedText.prefix(3))
        maxMemberCountTextField.text = truncatedString
        guard maxMemberCountTextField.text?.isEmpty == false else {
            maxMemberCountTextField.becomeFirstResponder()
            return false
        }
        guard let intNumber = Int(truncatedString), intNumber > 0, intNumber <= 100 else
        {
            maxMemberCountTextField.becomeFirstResponder()
            return false
        }
        return true
    }
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.updateScrollViewState(for: self.traitCollection)
        }, completion: nil)
    }

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateScrollViewState(for: traitCollection)
    }

    private func updateScrollViewState(for traitCollection: UITraitCollection) {
        if traitCollection.horizontalSizeClass == .compact && traitCollection.verticalSizeClass == .regular {
            scrollView.isScrollEnabled = false
        } else {
            scrollView.isScrollEnabled = true
        }
    }
}

extension KlatCreateChannelViewController {
    
    override public func imagePickerController(_ picker: UIImagePickerController,
                                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var image:UIImage?
        if let editedImage = info[.editedImage] as? UIImage {
            image = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            image = originalImage
        }
        
        if let image = image {
            channelImage.image = image
            channelImage.layer.cornerRadius = channelImage.frame.width / 2
            channelImage.contentMode = .scaleToFill
            isChannelImageUpdated = true
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    
}


extension KlatCreateChannelViewController: UITextFieldDelegate {
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        DispatchQueue.main.async {
            let endPosition = textField.endOfDocument
            textField.selectedTextRange = textField.textRange(from: endPosition, to: endPosition)
        }
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else {
            return false
        }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        if textField.tag == KlatTextFieldTag.maxMemberCount.rawValue {
            return updatedText.count <= 3
        }
        channelNameCountLabel.text = "\(updatedText.count)/30"
        return updatedText.count <= 30
    }
    
}
