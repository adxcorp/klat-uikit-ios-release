
import UIKit
import TalkPlus

class KlatMemberInfoViewController: KlatBaseViewController {
    
    var channel:TPChannel?
    var targetMemberId:String?
    var targetMemberName:String?
    var targetMemberProfileImageUrl:String?
    var didPrivateChatTapped:((TPUser) -> Void)?
    private var viewModel:KlatMemberInfoViewModel!
    
    @IBOutlet weak var contentHeight: NSLayoutConstraint!
    @IBOutlet weak var oneToOneChatStackView: UIStackView!
    @IBOutlet weak var muteUnmuteStackView: UIStackView!
    @IBOutlet weak var banStackView: UIStackView!
    @IBOutlet weak var operatorStackView: UIStackView! {
        didSet {
            operatorStackView.layer.cornerRadius = 20
            operatorStackView.layer.borderWidth = 1
            operatorStackView.layer.borderColor = UIColor.Background.layerGrayColor2.cgColor
            operatorStackView.clipsToBounds = true
            let gesture = UITapGestureRecognizer(target: self, action: #selector(operatorStackViewTapped))
            operatorStackView.addGestureRecognizer(gesture)
        }
    }
    
    @IBOutlet weak var operatorImageView: UIImageView!
    @IBOutlet weak var operatorLabel: UILabel!
    
    @IBOutlet weak var muteUnmuteLabel: UILabel!
    @IBOutlet weak var banLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var closeButton: UIButton! {
        didSet {
            closeButton.setTitle("", for: .normal)
        }
    }
    @IBOutlet weak var memberProfileImageView: UIImageView! {
        didSet {
            memberProfileImageView.layer.cornerRadius = self.memberProfileImageView.frame.width / 2
            memberProfileImageView.contentMode = .scaleAspectFit
            memberProfileImageView.layer.borderWidth = 0.1
            memberProfileImageView.layer.borderColor = UIColor.Background.layerGrayColor1.cgColor
        }
    }
    @IBOutlet weak var memberNameLabel: UILabel!
    @IBOutlet weak var oneToOneChatImageView: UIImageView! {
        didSet {
            oneToOneChatImageView.isUserInteractionEnabled = true
            let gesture = UITapGestureRecognizer(target: self, action: #selector(oneToOneChatImageViewTapped))
            oneToOneChatImageView.addGestureRecognizer(gesture)
        }
    }
    @IBOutlet weak var muteUnmuteImageView: UIImageView! {
        didSet {
            muteUnmuteImageView.isUserInteractionEnabled = true
            let gesture = UITapGestureRecognizer(target: self, action: #selector(muteUnmuteImageViewTapped))
            muteUnmuteImageView.addGestureRecognizer(gesture)
        }
    }
    @IBOutlet weak var banImageView: UIImageView! {
        didSet {
            banImageView.isUserInteractionEnabled = true
            let gesture = UITapGestureRecognizer(target: self, action: #selector(banImageViewTapped))
            banImageView.addGestureRecognizer(gesture)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        containerView.layer.cornerRadius = 12
        
        setupViewModel()
        setupView()
    }
    
    
    deinit {
        klatPrint(String(describing: type(of: self)), #function)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        klatPrint(String(describing: type(of: self)), #function)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        klatPrint(String(describing: type(of: self)), #function)
        delegate?.childViewControllerDidDismiss()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let touch = touches.first , touch.view == self.view {
            self.dismiss(animated: true)
        }
    }
    
    private func setupView() {
        setupMemberProfileView()
        setupMemberInfoView()
        setupBanView()
        setupOperatorView()
        setupMuteUnmuteView()
        
        contentHeight.constant = 396
        let member = TPMember(dictionary: ["id":targetMemberId ?? ""])
        if viewModel.isLoginUser(member: member){
            banStackView.isHidden = true
            muteUnmuteStackView.isHidden = true
            oneToOneChatStackView.isHidden = true
            operatorStackView.isHidden = true
            contentHeight.constant = operatorStackView.frame.origin.y + operatorStackView.frame.size.height
        }
        
        if self.channel?.getType() == "invitationOnly", 
            self.channel?.getMembers().count ?? 0 >= 2
        {
            oneToOneChatStackView.isHidden = true
        }
    }
    
    private func setupViewModel() {
        guard let channel = self.channel else { return }
        
        viewModel = KlatMemberInfoViewModel(targetChannel: channel)
        
        viewModel.didMutedMemberUpdated = { [weak self] in
            guard let self = self else { return }
            setupMuteUnmuteView()
        }
        
        viewModel.didChatChannelChanged = { [weak self] channel in
            guard let self = self, let channel = channel else { return }
            self.channel = channel
            setupView()
        }
        
        viewModel.requestMutedMembers()
    }
        
    private func setupMemberInfoView() {
        guard let channel = self.channel else { return }
        guard let targetMemberId = targetMemberId else { return }
        guard let targetMemberName = targetMemberName else { return }
        guard let member = getTargetMember(channel: channel, memberId: targetMemberId) else {
            setupMemberNameLabel(userId: targetMemberId, userName: targetMemberName)
            return
        }
        var userName = member.getUsername() ?? ""
        if viewModel.isLoginUser(member: member) {
            userName = "\(userName)(나)"
        }
        setupMemberNameLabel(userId: targetMemberId, userName: userName)
    }
    
    private func setupMemberNameLabel(userId:String, userName:String) {
        memberNameLabel.text = userId
        if userName.count > 0 {
            memberNameLabel.text = userName
        }
    }
    
    private func setupMemberProfileView() {
        guard let profileImageUrl = self.targetMemberProfileImageUrl else { return }
        guard profileImageUrl.count > 0 else { return }
        UIImage.loadImage(from: profileImageUrl) { [weak self] image, _ in
            guard let image = image else { return }
            self?.memberProfileImageView.image = image
        }
    }
    
    private func setupMuteUnmuteView() {
        guard let channel = channel else { return }
        guard let targetMemberId = self.targetMemberId else { return }
        let member = TPMember(dictionary: ["id":targetMemberId])
        if viewModel.isLoginUser(member: member){
            muteUnmuteStackView.isHidden = true
            return
        }
        muteUnmuteStackView.isHidden = false
        guard let _ = getTargetMember(channel: channel, memberId: targetMemberId) else {
            muteUnmuteStackView.isHidden = true
            return
        }
        let isMuted = viewModel.isMutedMember(memberId: targetMemberId)
        let image = UIImage(named: isMuted ? "KlatMuted" : "KlatUnMuted",
                            in: Bundle(for: type(of: self)),
                            compatibleWith:nil)
        muteUnmuteImageView.image = image
        muteUnmuteLabel.text = isMuted ? "음소거됨" : "음소거"
    }
    
    private func setupBanView() {
        guard let channel = self.channel else { return }
        banStackView.isHidden = false
        let isOwner = viewModel.isChannelOwner(channel: channel)
        if isOwner == false {
            banStackView.isHidden = true
            return
        }
        if viewModel.isMemberToChannel(userId: targetMemberId, channel: channel) == false {
            banStackView.isHidden = true
            return
        }
        let image = UIImage(named: "KlatUnblocked",
                            in: Bundle(for: type(of: self)),
                            compatibleWith:nil)
        banImageView.image = image
        banLabel.text = "강제퇴장"
    }
    
    private func setupOperatorView() {
        operatorStackView.isUserInteractionEnabled = false
        guard let channel = self.channel else { return }
        guard let targetMemberId = targetMemberId else { return }
        guard let _ = getTargetMember(channel: channel, memberId: targetMemberId) else {
            operatorStackView.isHidden = true
            return
        }
        
        if channel.getOwnerId() == targetMemberId {
            operatorLabel.text = "운영자"
            let image = UIImage(named: "KlatOwner", in: Bundle(for: type(of: self)), compatibleWith:nil)
            operatorImageView.image = image
            return
        }
        
        let isChannelOwner = viewModel.isChannelOwner(channel: channel)
        if isChannelOwner == false {
            operatorStackView.isHidden = true
            return
        }
        
        let image = UIImage(named: "KlatAdd", in: Bundle(for: type(of: self)), compatibleWith:nil)
        operatorImageView.image = image
        operatorLabel.text = "운영자 권한 부여하기"
        operatorStackView.isUserInteractionEnabled = true
    }
    
    private func getTargetMember(channel:TPChannel, memberId:String) -> TPMember? {
        let members = channel.getMembers().compactMap { $0 as? TPMember}
        return members.first { $0.getId() == memberId }
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @objc private func oneToOneChatImageViewTapped() {
        guard let targetMemberId = targetMemberId, targetMemberId.count > 0 else { return }
        guard let user = TPUser(dictionary: ["id":targetMemberId]) else { return }
        requestOneToOneChat(user: user)
    }
    
    @objc private func muteUnmuteImageViewTapped() {
        guard let targetMemberId = targetMemberId else { return }
        guard let targetMemberName = targetMemberName else { return }
        let isMuted = viewModel.isMutedMember(memberId: targetMemberId)
        if isMuted {
            unmute(userId: targetMemberId)
            return
        }
        
        let alert = UIAlertController(title: "\(targetMemberName)\n사용자를 음소거할까요?",
                                      message: "선택한 사용자가 즉시 음소거되며,\n별도로 해제하지 않는 한 음소거 상태가 유지됩니다.",
                                      preferredStyle: .alert)
        let muteAction = UIAlertAction(title: "음소거", style: .default) { [weak self] _ in
            guard let self = self else { return }
            mute(userId: targetMemberId)
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in }
        alert.addAction(muteAction)
        alert.addAction(cancelAction)
        if let muteButton = alert.actions.first(where: { $0.title == "음소거" }) {
            muteButton.setValue(UIColor.red, forKey: "titleTextColor")
        }
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func banImageViewTapped() {
        guard let targetMemberId = targetMemberId else { return }
        guard let targetMemberName = targetMemberName else { return }
        let alert = UIAlertController(title: "\(targetMemberName)\n사용자를 강제퇴장 시킬까요?",
                                      message: "선택한 사용자가 즉시 퇴장됩니다.",
                                      preferredStyle: .alert)
        let banAction = UIAlertAction(title: "강퇴", style: .default) { [weak self] _ in
            self?.banMember(userId: targetMemberId)
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in }
        alert.addAction(banAction)
        alert.addAction(cancelAction)
        if let banButton = alert.actions.first(where: { $0.title == "강퇴" }) {
            banButton.setValue(UIColor.red, forKey: "titleTextColor")
        }
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func operatorStackViewTapped() {
        guard let targetMemberId = targetMemberId else { return }
        guard let targetMemberName = targetMemberName else { return }
        let alert = UIAlertController(title: "\(targetMemberName)에게\n운영자 권한을 부여할까요?",
                                      message: "선택한 사용자가 즉시 운영자로 변경되며,\n해당 채널의 권한이 부여됩니다.",
                                      preferredStyle: .alert)
        let transferAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            guard let self = self else { return }
            transferChannelOwner(userId: targetMemberId)
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in }
        
        alert.addAction(transferAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func banMember(userId:String) {
        Task {
            do {
                try await viewModel.banMember(userId: userId)
            } catch {
                showKlatToast("\(error.localizedDescription)")
            }
        }
    }
    
    private func transferChannelOwner(userId: String) {
        Task {
            do {
                try await viewModel.transferChannelOwner(userId: userId)
            } catch {
                showKlatToast("\(error.localizedDescription)")
            }
        }
    }
    
    private func mute(userId:String) {
        Task {
            do {
                try await viewModel.mute(userId: userId)
            } catch {
                showKlatToast("\(error.localizedDescription)")
            }
        }
    }
    
    private func unmute(userId:String) {
        Task {
            do {
                try await viewModel.unmute(userId: userId)
            } catch {
                showKlatToast("\(error.localizedDescription)")
            }
        }
    }
    
    private func requestOneToOneChat(user: TPUser?) {
        Task {
            do {
                try await viewModel.requestOneToOneChat(targetUser: user)
            } catch {
                showKlatToast("\(error.localizedDescription)")
            }
        }
    }
    
}
