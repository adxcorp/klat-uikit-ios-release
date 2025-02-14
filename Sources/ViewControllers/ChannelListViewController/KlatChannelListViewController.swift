import UIKit
import TalkPlus

@objc public class KlatChannelListViewController: KlatBaseViewController {

    @IBOutlet weak var tableView: UITableView!

    private var channelCount = 0
    private var viewModel = KlatChannelListViewModel()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupChannelListTableView()
        setupNavigationBarAndItem()
        setupViewModel()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        klatPrint(String(describing: type(of: self)), #function)
        super.viewDidAppear(animated)
    }
    
    deinit {
        klatPrint(String(describing: type(of: self)), #function)
    }
    
    private func setupViewModel() {
        
        channelCount = viewModel.channels.count
        if channelCount == 0 {
            searchChannelButton.isEnabled = false
        }
        
        // New Channel Added or Removed
        viewModel.channelListUpdated = { [weak self] in
            guard let self = self else { return }
            channelCount = viewModel.channels.count
            if channelCount > 0 {
                searchChannelButton.isEnabled = true
                tableView.restore()
            } else {
                searchChannelButton.isEnabled = false
                setEmptyTableView()
            }
            UIView.performWithoutAnimation { [weak self] in
                self?.tableView.reloadData()
            }
        }
        
        viewModel.moveToPrivateChannel = { [weak self] privateChannel in
            self?.dismissAllPresentedViewControllers(animated: true) { [weak self] in
                let chatChannel = self?.viewModel.channels.filter { $0.getId() == privateChannel.getId() }.first
                self?.navigationController?.popToRootViewController(animated: true)
                self?.moveToChatChannel(channel: chatChannel)
            }
        }
        
        requestChatChannels()
    }
    
    private func requestChatChannels() {
        Task {
            do {
                startActivityIndicator()
                try await viewModel.requestChatChannels()
                stopActivityIndicator()
            } catch {
                await MainActor.run {
                    stopActivityIndicator()
                    handleKlatApiError(error: error, retryClosure: requestChatChannels)
                }
            }
        }
    }
    
    private func setEmptyTableView() {
        let image = UIImage(named: "KlatNoMessage", in: Bundle(for: type(of: self)), compatibleWith:nil)!
        let message = "아직 생성된 채널이 없습니다.\n채널을 생성하여 새로운 대화를 시작해보세요."
        tableView.setEmptyView(image: image, message: message)
    }
    
    private func setupChannelListTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        let tableViewCellId = String(describing: KlatChannelListTableViewCell.self)
        let nibName = UINib(nibName: tableViewCellId, bundle: Bundle(for: type(of: self)))
        tableView.register(nibName, forCellReuseIdentifier: tableViewCellId)
    }
    
    private lazy var leftBarButtons: UIBarButtonItem = {
        // Back(Close) Button
        let backButton = UIButton()
        backButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        let backImage = UIImage(named: "KlatBack", in: Bundle(for: type(of: self)), compatibleWith:nil)
        backButton.setImage(backImage, for: .normal)
        backButton.addTarget(self, action: #selector(closeButtonClicked), for: .touchUpInside)
        // titleLabel
        let titlelLabel = UILabel()
        titlelLabel.text = "채널"
        // StackView
        let stackView = UIStackView(arrangedSubviews: [backButton, titlelLabel])
        stackView.axis = .horizontal
        stackView.spacing = 24
        // BarButtonItem
        let barButtonItem = UIBarButtonItem(customView: stackView)
        barButtonItem.tintColor = .black
        return barButtonItem
    }()
    
    private lazy var searchChannelButton: UIButton = {
        let searchButton = UIButton()
        searchButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        let searchImage = UIImage(named: "KlatSearch", in: Bundle(for: type(of: self)), compatibleWith:nil)
        searchButton.setImage(searchImage, for: .normal)
        searchButton.addTarget(self, action: #selector(searchButtonClicked), for: .touchUpInside)
        return searchButton
    }()
    
    private lazy var addChannelButton: UIButton = {
        let addButton = UIButton()
        addButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        let addImage = UIImage(named: "KlatAddChannel", in: Bundle(for: type(of: self)), compatibleWith:nil)
        addButton.setImage(addImage, for: .normal)
        addButton.addTarget(self, action: #selector(addButtonClicked), for: .touchUpInside)
        return addButton
    }()
        
    private lazy var rightBarButtons: UIBarButtonItem = {
        // StackView
        let stackView = UIStackView(arrangedSubviews: [searchChannelButton, addChannelButton])
        stackView.axis = .horizontal
        stackView.spacing = 24
        // BarButtonItem
        let barButtonItem = UIBarButtonItem(customView: stackView)
        barButtonItem.tintColor = .black
        return barButtonItem
    }()
    
    private func setupNavigationBarAndItem() {
        // Back Button Image
        navigationController?.navigationBar.tintColor = .black
        let backImage = UIImage(named: "KlatBack", in: Bundle(for: type(of: self)), compatibleWith:nil)
        navigationController?.navigationBar.backIndicatorImage = backImage
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImage
        
        // Left BarButtonItem
        //navigationItem.leftBarButtonItem = leftBarButtons
        // Right BarButtonItem
        navigationItem.rightBarButtonItem = rightBarButtons
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }

    @objc func closeButtonClicked() {
        self.presentingViewController?.dismiss(animated: true)
    }
    
    @objc func searchButtonClicked() {
        let bundle = Bundle(for: KlatSearchChannelViewController.self)
        let nibName = String(describing: KlatSearchChannelViewController.self)
        let vc = KlatSearchChannelViewController(nibName: nibName, bundle: bundle)
        vc.chatChannels = viewModel.channels
        vc.chatChannelSelected = { [weak self] channel in
            self?.moveToChatChannel(channel: channel)
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func addButtonClicked() {
        let bundle = Bundle(for: KlatCreateChannelViewController.self)
        let nibName = String(describing: KlatCreateChannelViewController.self)
        let vc = KlatCreateChannelViewController(nibName: nibName, bundle: bundle)
        vc.newChatChannelCreated = { [weak self] newChannel in
            guard let self = self else { return }
            moveToChatChannel(channel: newChannel)
        }
        let naviVC = UINavigationController(rootViewController: vc)
        self.present(naviVC, animated: true)
    }
    
    private func showAlertViewController(channel:TPChannel?, message:String) {
        guard let channel = channel else { return }
        let alertController = UIAlertController(title: channel.getName(), message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { (action) in
            // Do nothin
        }
        alertController.addAction(cancelAction)
        
        let leaveAction = UIAlertAction(title: "나가기", style: .default) { [weak self] (action) in
            guard let self else { return }
            leaveChatChannel(channel: channel)
        }
        leaveAction.setValue(UIColor.red, forKey: "titleTextColor")
        alertController.addAction(leaveAction)
        
        present(alertController, animated: true)
    }
    
    private func leaveChatChannel(channel:TPChannel?) {
        Task {
            do {
                try await viewModel.leaveChatChannel(channel: channel)
            } catch {
                showKlatToast("\(error.localizedDescription)")
            }
        }
    }
    
    private func markAsRead(channel:TPChannel?) {
        Task {
            do {
                try await viewModel.markAsRead(channel: channel)
            } catch {
                showKlatToast("\(error.localizedDescription)")
            }
        }
    }
    
    private func moveToChatChannel(channel:TPChannel?) {
        guard let channel = channel else { return }
        let bundle = Bundle(for: KlatChatMessageViewController.self)
        let nibName = String(describing: KlatChatMessageViewController.self)
        let vc = KlatChatMessageViewController(nibName: nibName, bundle: bundle)
        vc.chatChannel = channel
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension KlatChannelListViewController: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.channels.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = "KlatChannelListTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? KlatChannelListTableViewCell else {
            return UITableViewCell()
        }
        let chatChannel = viewModel.channels[indexPath.row]
        cell.configure(chatChannel: chatChannel, tableView: tableView, indexPath: indexPath)
        cell.selectionStyle = .none
        return cell
    }
    
    public func tableView(_ tableView: UITableView,
                          trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let channelID = viewModel.channels[indexPath.row].getId() ?? ""
        // Action: Leave Channel
        let leaveAction = UIContextualAction(style: .destructive, title: "나가기") { [weak self] _, _, completionHandler in
            guard let self = self else { return }
            if let channel = viewModel.findChatChannel(channelID: channelID) {
                let message = "채널을 나가시겠어요?\n나간 채널의 대화는 저장되지 않습니다."
                showAlertViewController(channel: channel, message: message)
            }
            completionHandler(true)
        }
        leaveAction.backgroundColor = UIColor.init(klatHexCode: "F53D3D")
        
        // Action: Mark as a read
        let readAction = UIContextualAction(style: .normal, title: "읽음") { [weak self] _, _, completionHandler in
            guard let self else {
                completionHandler(true)
                return
            }
            if let channel = viewModel.findChatChannel(channelID: channelID) {
                markAsRead(channel: channel)
            }
            completionHandler(true)
        }
        readAction.backgroundColor = UIColor.init(klatHexCode: "5D81FF")

        let configuration = UISwipeActionsConfiguration(actions: [leaveAction, readAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let chatChannel = viewModel.channels[indexPath.row]
        moveToChatChannel(channel: chatChannel)
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
}
