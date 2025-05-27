
import UIKit
import TalkPlus

class KlatObservableNSLayoutConstraint: NSLayoutConstraint {
    var onConstantChanged: ((CGFloat) -> Void)?
    override var constant: CGFloat {
        didSet {
            onConstantChanged?(constant)
        }
    }
}

@objcMembers
public class KlatChatMessageViewController: KlatBaseViewController {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 338
        }
    }
    @IBOutlet weak var sendFileButton: UIButton!
    @IBOutlet weak var sendTextMessageButton: UIButton!
    @IBOutlet weak var messageInputTextView: UITextView!
    @IBOutlet weak var messageInputTextViewHeight: NSLayoutConstraint!
    @IBOutlet weak var messageInputStackView: UIStackView!
    
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var albumButton: UIButton!
    @IBOutlet weak var cameraLabel: UILabel!
    @IBOutlet weak var albumLabel: UILabel!
    @IBOutlet weak var sendFileContainerView: UIView!
    @IBOutlet weak var sendFileContainerHeight: KlatObservableNSLayoutConstraint!
    @IBOutlet weak var sendFileBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var channelInfoStackView: UIStackView!
    @IBOutlet weak var channelInfoContainer: UIView!
    @IBOutlet weak var channelInfoUpperLabel: UILabel!
    @IBOutlet weak var channelInfoLowerLabel: UILabel!
    @IBOutlet weak var channelInfoStackViewHeight: KlatObservableNSLayoutConstraint!
    
    private let placeholderLabel = UILabel()
    
    private var viewModel:KlatChatMessageViewModel!
    private var chatMessageCount = 0
    private var checkTimer: Timer?
    
    public var chatChannel: AnyObject?
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupViewModel()
        setupNavigationBarAndItem()
        setupMessageListTableView()
        setupSendOtherViews()
        setupMessageInputViews()
        setupRootView()
        setupKeyboardEvent()
        setTitle(channel: chatChannel as? TPChannel)
        setupChannelInfoContainer()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        klatPrint(String(describing: type(of: self)), #function)
    }
    
    deinit {
        klatPrint(String(describing: type(of: self)), #function)
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupChannelInfoContainer() {
        channelInfoUpperLabel.text = "운영자가 채널을 얼렸습니다."
        channelInfoUpperLabel.textColor = UIColor.KlatBlackColors.blackColor3
        channelInfoLowerLabel.text = "운영자를 제외한 사용자는 메시지를 입력할 수 없습니다."
        channelInfoLowerLabel.textColor = UIColor.klatDarkTealColor
        channelInfoContainer.backgroundColor = UIColor.klatLightMintColor
        channelInfoContainer.layer.cornerRadius = 8
        channelInfoStackViewHeight.onConstantChanged = { [weak self] newValue in
            guard let self = self else { return }
            channelInfoContainer.isHidden = (newValue <= 16)
            messageInputTextView.isUserInteractionEnabled = true
            sendFileContainerView.isUserInteractionEnabled = true
            sendFileButton.isUserInteractionEnabled = true
            if viewModel.isChannelOwner(channel: chatChannel as? TPChannel) == false {
                messageInputTextView.isUserInteractionEnabled = channelInfoContainer.isHidden
                sendFileContainerView.isUserInteractionEnabled = channelInfoContainer.isHidden
                sendFileButton.isUserInteractionEnabled = channelInfoContainer.isHidden
            }
            channelInfoStackView.layoutMargins = (newValue <= 16) ? .zero : .init(top: 16, left: 16, bottom: 16, right: 16)
        }
        let isFrozen = chatChannel?.isFrozen() ?? false
        channelInfoStackViewHeight.constant = isFrozen ? 102 : 16
        channelInfoStackViewHeight.priority = .defaultHigh
    }
    
    private func setupRootView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    func setupKeyboardEvent() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    private func setupMessageInputViews() {
        // Send Other Button
        var image = UIImage(named: "KlatPlus", in: Bundle(for: type(of: self)), compatibleWith:nil)
        sendFileButton.setTitle("", for: .normal)
        sendFileButton.setImage(image, for: .normal)
        sendFileButton.addTarget(self, action: #selector(sendFileButtonClicked), for: .touchUpInside)
        // Message Input TextView
        messageInputTextView.backgroundColor = UIColor.KlatGrayColors.grayColor3
        messageInputTextView.textColor = UIColor.KlatBlackColors.blackColor1
        messageInputTextView.layer.cornerRadius = 10
        messageInputTextView.delegate = self
        // Place Holder
        placeholderLabel.text = "메시지 입력"
        placeholderLabel.font = UIFont.systemFont(ofSize: 16)
        placeholderLabel.textColor = UIColor.KlatGrayColors.grayColor2
        placeholderLabel.frame = CGRect(x: 5, y: 8, width: messageInputTextView.frame.width - 10, height: 20)
        messageInputTextView.addSubview(placeholderLabel)
        // Send Message Button
        image = UIImage(named: "KlatSendMesage", in: Bundle(for: type(of: self)), compatibleWith:nil)
        sendTextMessageButton.setTitle("", for: .normal)
        sendTextMessageButton.setImage(image, for: .normal)
        sendTextMessageButton.layer.cornerRadius = 15
        sendTextMessageButton.addTarget(self, action: #selector(sendChatMessage), for: .touchUpInside)
        sendTextMessageButton.backgroundColor = UIColor.klatPrimaryColor
        sendTextMessageButton.isHidden = true
    }
    
    private func setupSendOtherViews() {
        // Camara Button
        cameraButton.setTitle("", for: .normal)
        var image = UIImage(named: "KlatCamera", in: Bundle(for: type(of: self)), compatibleWith:nil)
        cameraButton.setImage(image, for: .normal)
        cameraButton.addTarget(self, action: #selector(cameraButtonClicked), for: .touchUpInside)
        cameraLabel.textColor = UIColor.KlatBlackColors.blackColor2
        // Album Button
        albumButton.setTitle("", for: .normal)
        image = UIImage(named: "KlatPicture", in: Bundle(for: type(of: self)), compatibleWith:nil)
        albumButton.setImage(image, for: .normal)
        albumButton.addTarget(self, action: #selector(albumButtonClicked), for: .touchUpInside)
        albumLabel.textColor = UIColor.KlatBlackColors.blackColor2
        // Container View
        sendFileContainerView.backgroundColor = UIColor.KlatGrayColors.grayColor4
        sendFileContainerView.isHidden = true
        // Container Height
        sendFileContainerHeight.onConstantChanged = { [weak self] newValue in
            guard let self = self else { return }
            sendFileContainerView.isHidden = (newValue == 0)
            let imageName = (newValue == 0) ? "KlatPlus" : "KlatXwithCircle"
            let image = UIImage(named: imageName, in: Bundle(for: type(of: self)), compatibleWith:nil)
            sendFileButton.setImage(image, for: .normal)
        }
        
        sendFileContainerHeight.constant = 0
    }
    
    private func markMessageAsRead() {
        guard presentedViewController == nil else { return }
        viewModel.markAsRead()
    }
    
    private func setupViewModel() {
        
        chatMessageCount = 0
        
        viewModel = KlatChatMessageViewModel(targetChannel: chatChannel as? TPChannel)
        
        viewModel.newMessageReceived = { [weak self] messages in
            guard let self = self else { return }
            
            tableView.restore()
            
            var newIndexPathArray:[IndexPath] = []
            var reloadIndexPathArray:[IndexPath] = []
            for _ in messages {
                chatMessageCount += 1
                let indexPath = IndexPath(row: chatMessageCount - 1, section: 0)
                newIndexPathArray.append(indexPath)
                if chatMessageCount - 2 >= 0 {
                    let reloadInxPath = IndexPath(row: chatMessageCount - 2, section: 0)
                    reloadIndexPathArray.append(reloadInxPath)
                }
            }
            
            UIView.performWithoutAnimation { [weak self] in
                self?.tableView.insertRows(at: newIndexPathArray, with: .none)
                self?.tableView.reloadRows(at: reloadIndexPathArray, with: .none)
            }
            
            markMessageAsRead()
            moveScrollToBottom()
        }
        
        viewModel.moreMessageReceived = { [weak self] in
            guard let self = self else { return }
            chatMessageCount = viewModel.messages.count
            UIView.performWithoutAnimation { [weak self] in
                self?.tableView.reloadData()
            }
        }
        
        viewModel.messageDeleted = { [weak self] messages, indexes in
            guard let self = self else { return }
            chatMessageCount = self.viewModel.messages.count
            var indexPaths:[IndexPath] = []
            for index in indexes { indexPaths.append(IndexPath(row: index, section: 0)) }
            tableView.deleteRows(at: indexPaths, with: .none)
            for index in indexes {
                let prevIndex = index - 1
                if prevIndex < 0 { continue }
                indexPaths.append(IndexPath(row: prevIndex, section: 0))
            }
            tableView.reloadRows(at: indexPaths, with: .none)
            setEmptyTableView()
        }
        
        viewModel.channelDataUpdated = { [weak self] channel, _ in
            guard let self = self else { return }
            chatChannel = channel
            setTitle(channel: channel)
            updateMessageContents(channel: channel)
            if channel.isFrozen() {
                channelInfoStackViewHeight.constant = 102
            } else {
                channelInfoStackViewHeight.constant = 16
            }
        }
        
        viewModel.didChannelLeftOrDeleted = { [weak self] in
            self?.dismissAllPresentedViewControllers(animated: true) { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
        }
        
        viewModel.reactionUpdated = { [weak self] _ , index in
            let indexPath = IndexPath(row: index, section: 0)
            self?.tableView.reloadRows(at: [indexPath], with: .none)
        }
        
        requestChatMessage()
    }
    
    private func setupNavigationBarAndItem() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.barTintColor = UIColor.klatClearColor
        navigationItem.hidesBackButton = true
        if let navigationController = self.navigationController,
           let index = navigationController.viewControllers.firstIndex(of: self), index != 0 {
            navigationItem.leftBarButtonItem = backBarButton
        }
        navigationItem.rightBarButtonItem = channelActionBarButton
    }
    
    private func setTitle(channel:TPChannel?) {
        guard let targetChannel = channel else { return }
        guard let channelName = targetChannel.getName() else { return }
        self.title = channelName
    }
    
    private func updateMessageContents(channel:TPChannel?) {
        guard let channel = channel else { return }
        var count = 0
        for message in viewModel.messages {
            updateUnreadCount(count, channel, message)
            count += 1
        }
    }
                
    private func updateUnreadCount(_ index:Int, _ channel:TPChannel, _ message:TPMessage) {
        let indexPath = IndexPath(row: index, section: 0)
        if let cell = tableView.cellForRow(at: indexPath) as? KlatChatMessageProtocol {
            cell.updateUnreadCountLabel(channel: channel, message: message)
        }
    }
    
    private lazy var backBarButton: UIBarButtonItem = {
        let backButton = UIButton()
        backButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        let buttonImage = UIImage(named: "KlatBack", in: Bundle(for: type(of: self)), compatibleWith:nil)
        backButton.setImage(buttonImage, for: .normal)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return UIBarButtonItem(customView: backButton)
    }()
    
    private lazy var channelActionBarButton: UIBarButtonItem = {
        let channelActionButton = UIButton()
        channelActionButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        let buttonImage = UIImage(named: "KlatChannelInfo", in: Bundle(for: type(of: self)), compatibleWith:nil)
        channelActionButton.setImage(buttonImage, for: .normal)
        channelActionButton.addTarget(self, action: #selector(channelActionButtonTapped), for: .touchUpInside)
        return UIBarButtonItem(customView: channelActionButton)
    }()
    
    private func setupMessageListTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        let tableViewCellIds = ["KlatMyChatMessageCell", "KlatYourChatMessageCell"]
        for cellId  in tableViewCellIds {
            let nibName = UINib(nibName: cellId, bundle: Bundle(for: type(of: self)))
            tableView.register(nibName, forCellReuseIdentifier: cellId)
        }
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = 0.5
        tableView.addGestureRecognizer(longPressGesture)
    }
    
    private func setEmptyTableView() {
        guard viewModel.messages.count == 0 else { return }
        let image = UIImage(named: "KlatNoMessage", in: Bundle(for: type(of: self)), compatibleWith:nil)!
        let message = "아직 채널에 메시지가 없어요.\n제일 먼저 메시지를 남겨보세요."
        DispatchQueue.main.async { [weak self] in
            self?.tableView.setEmptyView(image: image, message: message)
        }
    }
    
    private func confirmDeleteChatMeesage(chatMessage:TPMessage) {
        let alert = UIAlertController(title: "메시지를 삭제할까요?",
                                      message: "메시지는 즉시 나와 상대방에게 삭제되며 복구되지 않습니다.",
                                      preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "삭제", style: .default) { [weak self] _ in
            self?.deleteMessage(chatMessage: chatMessage)
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
            
        }
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        if let deleteButton = alert.actions.first(where: { $0.title == "삭제" }) {
            deleteButton.setValue(UIColor.klatRedColor, forKey: "titleTextColor")
        }
        
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Klat API Call
extension KlatChatMessageViewController {
    
    private func requestChatMessage() {
        Task {
            do {
                startActivityIndicator() { [weak self] in
                    self?.messageInputStackView.isHidden = true
                    self?.channelActionBarButton.isEnabled = false
                }
                let chatChannel = chatChannel as? TPChannel
                try await viewModel.requestChatMessages(lastMessage: nil, targetChannel: chatChannel)
                setEmptyTableView()
                stopActivityIndicator() { [weak self] in
                    self?.messageInputStackView.isHidden = false
                    self?.channelActionBarButton.isEnabled = true
                }
            } catch {
                stopActivityIndicator() { [weak self] in
                    guard let self = self else { return }
                    messageInputStackView.isHidden = false
                    channelActionBarButton.isEnabled = true
                    handleKlatApiError(error: error, retryClosure: requestChatMessage)
                }
            }
        }
    }
    
    private func deleteMessage(chatMessage:TPMessage) {
        Task {
            do {
                try await viewModel.deleteMessage(message: chatMessage)
            } catch {
                showKlatToast("\(error.localizedDescription)")
            }
        }
    }
    
    private func sendChatMessageToChannel(params:TPMessageSendParams) {
        Task {
            do {
                try await viewModel.sendMessage(params: params)
            } catch {
                showKlatToast("\(error.localizedDescription)")
            }
        }
    }
    
    private func requestMoreChatMessage() {
        guard let channel = chatChannel as? TPChannel else { return }
        Task {
            do {
                startActivityIndicator()
                try await viewModel.getMoreChatMessages(targetChannel: channel)
                stopActivityIndicator()
            } catch {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    stopActivityIndicator()
                    handleKlatApiError(error: error, retryClosure: requestMoreChatMessage)
                }
            }
        }
    }
    
    private func addEmojiToMessage(message:TPMessage?, emoji:String){
        Task {
            do {
                try await viewModel.addEmojiToMessage(message: message, emoji: emoji)
                if viewModel.isMessageAtLast(message: message) {
                    try await Task.sleep(nanoseconds: 200_000_000) // 200ms
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        moveScrollToBottom()
                    }
                }
            } catch {
                showKlatToast("\(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Touch Events, Keyboard Events
extension KlatChatMessageViewController {
    
    @objc func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func channelActionButtonTapped() {
        let bundle = Bundle(for: KlatChannelActionViewController.self)
        let nibName = String(describing: KlatChannelActionViewController.self)
        let vc = KlatChannelActionViewController(nibName: nibName, bundle: bundle)
        let chatChannel = chatChannel as? TPChannel
        let channel = viewModel.findChatChannel(channelID: chatChannel?.getId() ?? "")
        vc.channel = channel
        vc.channelActionViewDidDisappear = { [weak self] in
            Task {
                try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
                self?.markMessageAsRead()
            }
        }
        let naviVC = UINavigationController(rootViewController: vc)
        self.present(naviVC, animated: true, completion: nil)
    }
    
    @objc func cameraButtonClicked() {
        openCamera()
    }
    
    @objc func albumButtonClicked() {
        openAlbum()
    }
        
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        sendTextMessageButton.isHidden = false
        moveScrollToBottom()
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = keyboardFrame.height
            sendFileBottomConstraint.constant = 0
            sendFileBottomConstraint.constant -= keyboardHeight
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.view.layoutIfNeeded()
            }
        }
    }

    @objc func keyboardWillHide(notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            sendTextMessageButton.isHidden = true
            sendFileBottomConstraint.constant = 0
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func sendFileButtonClicked() {
        changeSendFileContainerHeight()
    }
    
    private func changeSendFileContainerHeight() {
        let constant = sendFileContainerHeight.constant == 0 ? 144.0 : 0
        sendFileContainerHeight.constant = constant
    }
    
    @objc private func moveScrollToBottom() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard chatMessageCount > 0 else { return }
            let lastIndexPath = IndexPath(row: chatMessageCount - 1, section: 0)
            tableView.scrollToRow(at: lastIndexPath, at: .none, animated: true)
        }
    }
    
    @objc private func sendChatMessage() {
        guard let channel = self.chatChannel as? TPChannel else { return }
        let message = messageInputTextView.text ?? ""
        guard message.isEmpty == false else { return }
        messageInputTextView.text = ""
        messageInputTextViewHeight.constant = 36
        if let params = TPMessageSendParams(contentType: .text, messageType: .text, channel: channel) {
            params.textMessage = message
            sendChatMessageToChannel(params: params)
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension KlatChatMessageViewController: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessageCount
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Message at index
        let message = viewModel.messages[indexPath.row]
        // Prev message
        var prevMessage:TPMessage? = nil
        if indexPath.row - 1 >= 0 {
            prevMessage = viewModel.messages[indexPath.row - 1]
        }
        // Next message
        var nextMessage:TPMessage? = nil
        if indexPath.row + 1 < viewModel.messages.count {
            nextMessage = viewModel.messages[indexPath.row + 1]
        }
        // TableViewCell ID
        let isMyMessage = viewModel.isMyMessage(message: message)
        let cellId = isMyMessage ? "KlatMyChatMessageCell" : "KlatYourChatMessageCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        if var chatCell = cell as? KlatChatMessageProtocol, let channel = chatChannel as? TPChannel {
            chatCell.configure(channel: channel,
                               message: message,
                               otherMessages: (prevMessage, nextMessage),
                               tableView: tableView,
                               indexPath: indexPath)
            chatCell.didImageViewTapped = { [weak self] message in
                guard let message = message else { return }
                let bundle = Bundle(for: KlatImageViewerViewController.self)
                let nibName = String(describing: KlatImageViewerViewController.self)
                let vc = KlatImageViewerViewController(nibName: nibName, bundle: bundle)
                vc.chatMessage = message
                let vcWithNav = UINavigationController(rootViewController: vc)
                vcWithNav.modalPresentationStyle = .fullScreen
                vcWithNav.modalTransitionStyle = .coverVertical
                self?.present(vcWithNav, animated: true, completion: nil)
            }
        }
        
        // My Message
        if (cell as? KlatYourChatMessageCell) == nil {
            return cell
        }
        
        // Your Message
        let yourCell = cell as! KlatYourChatMessageCell
        yourCell.didProfileImageViewTapped = { [weak self] channel, message in
            guard let self = self else { return }
            let bundle = Bundle(for: KlatMemberInfoViewController.self)
            let nibName = String(describing: KlatMemberInfoViewController.self)
            let vc = KlatMemberInfoViewController(nibName: nibName, bundle: bundle)
            let chatChannel = chatChannel as? TPChannel
            let channel = viewModel.findChatChannel(channelID: chatChannel?.getId() ?? "")
            vc.channel = channel
            vc.targetMemberId = message.getUserId()
            vc.targetMemberName = message.getUsername()
            vc.targetMemberProfileImageUrl = message.getUserProfileImage()
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true)
        }
        
        return yourCell
    }
    
    @objc func handleLongPress(longPressGesture: UILongPressGestureRecognizer) {
        guard longPressGesture.state != UIGestureRecognizer.State.began else { return }
        let p = longPressGesture.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: p)
        guard let indexPath = indexPath else { return }
        guard indexPath.row < viewModel.messages.count, viewModel.messages.count != 0 else { return }
        let chatMessage = viewModel.messages[indexPath.row]
        let bundle = Bundle(for: KlatMessageActionViewController.self)
        let nibName = String(describing: KlatMessageActionViewController.self)
        let vc = KlatMessageActionViewController(nibName: nibName, bundle: bundle)
        vc.chatMessage = chatMessage
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        vc.didDeleteButtonTapped = { [weak self] message in
            self?.confirmDeleteChatMeesage(chatMessage: message)
        }
        
        vc.didEmojiButtonTapped = { [weak self] message, emoji in
            self?.addEmojiToMessage(message: message, emoji: emoji)
        }
        self.present(vc, animated: true, completion: nil)
    }
    
}

// MARK: - UITextViewDelegate
extension KlatChatMessageViewController: UIScrollViewDelegate {
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            checkIfFirstCellIsVisible(scrollView)
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        checkIfFirstCellIsVisible(scrollView)
    }
    
    private func checkIfFirstCellIsVisible(_ scrollView: UIScrollView) {
        guard let tableView = scrollView as? UITableView else { return }
        if let firstVisibleCell = tableView.visibleCells.first,
           let firstIndexPath = tableView.indexPath(for: firstVisibleCell) {
            if firstIndexPath.row != 0 { return }
            requestMoreChatMessage()
        }
    }
}


// MARK: - UITextViewDelegate
extension KlatChatMessageViewController: UITextViewDelegate {
    
    public func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        let size = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude))
        if size.height >= 100 {
            messageInputTextViewHeight.constant = 100
            view.layoutIfNeeded()
        }
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = true
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}

extension KlatChatMessageViewController {
    
    override public func imagePickerController(_ picker: UIImagePickerController,
                                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        let params = TPMessageSendParams(contentType: .file,
                                         messageType: .text,
                                         channel: chatChannel as? TPChannel)
        
        if picker.sourceType == .photoLibrary || picker.sourceType == .camera {
            var image:UIImage?
            if let editedImage = info[.editedImage] as? UIImage {
                image = editedImage
            } else if let originalImage = info[.cropRect] as? UIImage {
                image = originalImage
            }
            let documentURLs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            let imageURL = documentURLs?.appendingPathComponent("image.jpg")
            
            let resizedImage = viewModel.resizeImageToFit(screenSize: UIScreen.main.bounds.size, image: image)
            if let imagePath = imageURL?.path, let imageData = viewModel.getImageData(image: resizedImage, quality: 1.0) {
                do {
                    try imageData.write(to: imageURL!)
                    params?.filePath = imagePath
                } catch {
                    showKlatToast("\(error.localizedDescription)")
                }
            }
        }
        
        if let params = params, params.filePath.count > 0 {
            params.textMessage = "사진을 보냈습니다."
            sendChatMessageToChannel(params: params)
            changeSendFileContainerHeight()
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
}
