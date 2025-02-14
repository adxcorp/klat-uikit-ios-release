
import UIKit
import TalkPlus

class KlatChannelActionViewController: KlatBaseViewController {

    var channel:TPChannel?
    var channelActionViewDidDisappear:(()->())?
    
    private var viewModel:KlatChannelActionViewModel!
    
    deinit {
        klatPrint(String(describing: type(of: self)), #function)
    }
    
    @IBOutlet weak var channelNameLabel: UILabel!
    @IBOutlet weak var channelMemberCountLabel: UILabel!
    @IBOutlet weak var channelActionStackView: UIStackView!
    
    @IBOutlet weak var changeChannelNameStackView: UIStackView! {
        didSet {
            let gesture = UITapGestureRecognizer(target: self, action: #selector(changeChannelInfoTapped))
            changeChannelNameStackView.addGestureRecognizer(gesture)
        }
    }
    @IBOutlet weak var memberListStackView: UIStackView! {
        didSet {
            let gesture = UITapGestureRecognizer(target: self, action: #selector(memberListTapped))
            memberListStackView.addGestureRecognizer(gesture)
        }
    }
    @IBOutlet weak var restrictedListStackView: UIStackView! {
        didSet {
            let gesture = UITapGestureRecognizer(target: self, action: #selector(restrictedListTapped))
            restrictedListStackView.addGestureRecognizer(gesture)
        }
    }
    @IBOutlet weak var addMemberStackView: UIStackView! {
        didSet {
            let gesture = UITapGestureRecognizer(target: self, action: #selector(addMemberTapped))
            addMemberStackView.addGestureRecognizer(gesture)
        }
    }
    @IBOutlet weak var deleteChannelStackView: UIStackView! {
        didSet {
            let gesture = UITapGestureRecognizer(target: self, action: #selector(deleteChannelTapped))
            deleteChannelStackView.addGestureRecognizer(gesture)
        }
    }
    
    @IBOutlet weak var leaveChannelStackView: UIStackView! {
        didSet {
            let gesture = UITapGestureRecognizer(target: self, action: #selector(leaveChannelTapped))
            leaveChannelStackView.addGestureRecognizer(gesture)
        }
    }
    
    @IBOutlet weak var freezeChannelSwitch: UISwitch! {
        didSet {
            freezeChannelSwitch.addTarget(self, action: #selector(freezeChannelSwitchValueChanged(_:)), for: .valueChanged)
            guard let isFrozen = self.channel?.isFrozen() else { return }
            freezeChannelSwitch.isOn = isFrozen
        }
    }
    @IBOutlet weak var pushSettingSwitch: UISwitch! {
        didSet {
            guard let isPushDisabled = self.channel?.isPushNotificationDisabled() else { return }
            pushSettingSwitch.isOn = !isPushDisabled
            pushSettingSwitch.addTarget(self, action: #selector(pushSettingSwitchValueChanged(_:)), for: .valueChanged)
        }
    }
    
    @IBOutlet weak var channelImageView: UIImageView! {
        didSet {
            channelImageView.layer.cornerRadius = channelImageView.frame.width / 2
            channelImageView.layer.borderWidth = 0.1
            channelImageView.layer.borderColor = UIColor.Background.layerGrayColor1.cgColor
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupNavigationItem()
        setupChannelActionMenu()
        setupChannelImageView()
        setupViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        klatPrint(String(describing: type(of: self)), #function)
        setupChannelInfoLabel()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        klatPrint(String(describing: type(of: self)), #function)
        channelActionViewDidDisappear?()
    }
    
    private func setupViewModel() {
        viewModel = KlatChannelActionViewModel()
        viewModel.channel = self.channel
        viewModel.didChannelChanged = { [weak self] chatChannel in
            guard let self = self else { return }
            channel = chatChannel
            setupChannelInfoLabel()
            setupChannelImageView()
            setupChannelActionMenu()
        }
    }
    
    private func setupChannelImageView() {
        let image = UIImage(named: "KlatDefaultChannelImage", in: Bundle(for: type(of: self)), compatibleWith:nil)
        channelImageView.image = image
        guard let imageUrlString = channel?.getImageUrl(), imageUrlString.count > 0 else { return }
        UIImage.loadImage(from: imageUrlString) { [weak self] image, _ in
            self?.channelImageView.image = image
        }
    }
    
    private func setupChannelActionMenu() {
        guard let channel = channel else { return }
        guard let userId = KlatChatAPIs.shared.loginUser?.getId() else { return }
        if channel.getOwnerId() == userId {
            for subview in channelActionStackView.arrangedSubviews {
                if subview as? UIStackView == nil { continue }
                subview.isHidden = !(subview.tag <= 200)
            }
        } else {
            for subview in channelActionStackView.arrangedSubviews {
                if subview as? UIStackView == nil { continue }
                subview.isHidden = !(subview.tag >= 200 && subview.tag < 400)
            }
        }
    }
    
    private func setupChannelInfoLabel() {
        if let channel = self.channel {
            let channelName = channel.getName() ?? ""
            channelNameLabel.text = channelName
            channelMemberCountLabel.text = "\(channel.getMembers().count)명 참여중"
        }
    }
    
    private func setupNavigationItem() {
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
}

extension KlatChannelActionViewController {
    
    @objc private func closeButtonTapped() {
        self.presentingViewController?.dismiss(animated: true)
    }
    
    @objc private func restrictedListTapped() {
        let bundle = Bundle(for: KlatRestrictedListViewController.self)
        let nibName = String(describing: KlatRestrictedListViewController.self)
        let vc = KlatRestrictedListViewController(nibName: nibName, bundle: bundle)
        vc.channel = self.channel
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func memberListTapped() {
        let bundle = Bundle(for: KlatMemberListViewController.self)
        let nibName = String(describing: KlatMemberListViewController.self)
        let vc = KlatMemberListViewController(nibName: nibName, bundle: bundle)
        vc.channel = self.channel
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func changeChannelInfoTapped() {
        let bundle = Bundle(for: KlatEditChannelViewController.self)
        let nibName = String(describing: KlatEditChannelViewController.self)
        let vc = KlatEditChannelViewController(nibName: nibName, bundle: bundle)
        vc.channel = self.channel
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func deleteChannelTapped() {
        let alert = UIAlertController(title: "\(channelNameLabel.text ?? "")\n채널을 삭제할까요?",
                                      message: "채널은 즉시 삭제되며, 대화 기록은 저장되지 않고 복구할 수 없습니다.",
                                      preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in }
        let deleteAction = UIAlertAction(title: "삭제", style: .default) { [weak self] _ in
            self?.deleteChatChannel()
        }
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        if let deleteButton = alert.actions.first(where: { $0.title == "삭제" }) {
            deleteButton.setValue(UIColor.red, forKey: "titleTextColor")
        }
        present(alert, animated: true, completion: nil)
    }

    @objc private func leaveChannelTapped() {
        let alert = UIAlertController(title: "\(channelNameLabel.text ?? "")\n채널을 나갈까요?",
                                      message: "채널에서 즉시 퇴장하며, 대화 기록은 저장되지 않고 복구할 수 없습니다.",
                                      preferredStyle: .alert)
        let leaveAction = UIAlertAction(title: "나가기", style: .default) { [weak self] _ in
            guard let self = self else { return }
            leaveChatChannel()
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in }
        alert.addAction(leaveAction)
        alert.addAction(cancelAction)
        if let leaveButton = alert.actions.first(where: { $0.title == "나가기" }) {
            leaveButton.setValue(UIColor.red, forKey: "titleTextColor")
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func addMemberTapped() {
        klatPrint(#function)
    }
    
    @objc private func freezeChannelSwitchValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            freezeChatChannel()
            return
        }
        unfreezeChatChannel()
    }
    
    @objc private func pushSettingSwitchValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            enableChannelPushNotification()
            return
        }
        disableChannelPushNotification()
    }
}

extension KlatChannelActionViewController {
    
    private func freezeChatChannel() {
        Task {
            do {
                try await viewModel.freezeChatChannel()
            } catch {
                freezeChannelSwitch.isOn = false
                showKlatToast("\(error.localizedDescription)")
            }
        }
    }
    
    private func unfreezeChatChannel() {
        Task {
            do {
                try await viewModel.unfreezeChatChannel()
            } catch {
                freezeChannelSwitch.isOn = true
                showKlatToast("\(error.localizedDescription)")
            }
        }
    }
    
    private func enableChannelPushNotification() {
        Task {
            do {
                try await viewModel.enableChannelPushNotification()
            } catch {
                pushSettingSwitch.isOn = false
                showKlatToast("\(error.localizedDescription)")
            }
        }
    }
    
    private func disableChannelPushNotification() {
        Task {
            do {
                try await viewModel.disableChannelPushNotification()
            } catch {
                pushSettingSwitch.isOn = true
                showKlatToast("\(error.localizedDescription)")
            }
        }
    }
    
    private func leaveChatChannel() {
        Task {
            do {
                try await viewModel.leaveChatChannel()
            } catch {
                showKlatToast("\(error.localizedDescription)")
            }
        }
    }
    
    private func deleteChatChannel() {
        Task {
            do {
                try await viewModel.deleteChatChannel()
            } catch {
                showKlatToast("\(error.localizedDescription)")
            }
        }
    }
}
