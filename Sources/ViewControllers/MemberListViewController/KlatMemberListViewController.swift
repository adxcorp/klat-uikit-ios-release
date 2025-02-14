
import UIKit
import TalkPlus

class KlatMemberListViewController: KlatBaseViewController {
    
    var channel:TPChannel?
    
    private var viewModel:KlatMemberListViewModel!
    private var memberCount = 0
    
    @IBOutlet weak var tableView: UITableView!
    
    deinit {
        klatPrint(String(describing: type(of: self)), #function)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupViewModel()
        setupNavigationItem()
        setupMemberListTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        klatPrint(String(describing: type(of: self)), #function)
    }
    
    private func setupViewModel() {
        viewModel = KlatMemberListViewModel(targetChannel: self.channel)
        
        viewModel.channelMemberUpdated = { [weak self] channel in
            self?.channel = channel
            self?.memberCount = self?.viewModel.members.count ?? 0
            self?.tableView.reloadData()
        }
    }
    
    private func setupMemberListTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        let tableViewCellId = String(describing: KlatMemberListTableViewCell.self)
        let nibName = UINib(nibName: tableViewCellId, bundle: Bundle(for: type(of: self)))
        tableView.register(nibName, forCellReuseIdentifier: tableViewCellId)
    }
    
    private func setupNavigationItem() {
        navigationItem.title = "참여자 목록"
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

}


extension KlatMemberListViewController {
    
    @objc private func closeButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension KlatMemberListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memberCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard memberCount > 0 else { return UITableViewCell() }
        let cellId = "KlatMemberListTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? KlatMemberListTableViewCell else {
            return UITableViewCell()
        }
        let member = viewModel.members[indexPath.row]
        cell.configure(channel: channel, member: member)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let userId = viewModel.members[indexPath.row].getId()
        //guard userId != KlatChatAPIs.shared.loginUser?.getId() else { return }
        let userName = viewModel.members[indexPath.row].getUsername()
        let profileImageUrl = viewModel.members[indexPath.row].getProfileImageUrl()
        let bundle = Bundle(for: KlatMemberInfoViewController.self)
        let nibName = String(describing: KlatMemberInfoViewController.self)
        let vc = KlatMemberInfoViewController(nibName: nibName, bundle: bundle)
        vc.channel = channel
        vc.targetMemberId = userId
        vc.targetMemberName = userName
        vc.targetMemberProfileImageUrl = profileImageUrl
        vc.delegate = self
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true)
    }
}

extension KlatMemberListViewController: KlatChildViewControllerDelegate {
    
    func childViewControllerDidDismiss() {
        
    }
    
}
    
