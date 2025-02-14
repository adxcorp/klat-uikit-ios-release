
import UIKit
import TalkPlus

class KlatRestrictedListViewController: KlatBaseViewController {

    var channel:TPChannel?
    private var viewModel:KlatRestrictedListViewModel!
    private var memberCount = 0
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupNavigationItem()
        setupMemberListTableView()
        setupViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        klatPrint(String(describing: type(of: self)), #function)
    }
    
    private func setupViewModel() {
        viewModel = KlatRestrictedListViewModel(targetChannel: channel)
        
        viewModel.didMutedMemberUpdated = { [weak self] in
            guard let self = self else { return }
            memberCount = viewModel.mutedMembers.count
            tableView.reloadData()
        }
        
        viewModel.requestMutedMembers()
    }
    
    private func setupMemberListTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        let tableViewCellId = String(describing: KlatRestrictedListTableViewCell.self)
        let nibName = UINib(nibName: tableViewCellId, bundle: Bundle(for: type(of: self)))
        tableView.register(nibName, forCellReuseIdentifier: tableViewCellId)
    }
    
    private func setupNavigationItem() {
        navigationItem.title = "음소거 목록"
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

extension KlatRestrictedListViewController {
    @objc private func closeButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func setEmptyTableView() {
        let message = "음소거 된 멤버가 없습니다."
        tableView.setEmptyView(image: nil, message: message)
    }
}

extension KlatRestrictedListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if memberCount == 0 {
            setEmptyTableView()
            return 0
        }
        tableView.restore()
        return memberCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard memberCount > 0 else { return UITableViewCell() }
        let cellId = "KlatRestrictedListTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? KlatRestrictedListTableViewCell else {
            return UITableViewCell()
        }
        let member = viewModel.mutedMembers[indexPath.row]
        cell.configure(member: member)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let bundle = Bundle(for: KlatMemberInfoViewController.self)
        let nibName = String(describing: KlatMemberInfoViewController.self)
        let vc = KlatMemberInfoViewController(nibName: nibName, bundle: bundle)
        vc.channel = channel
        vc.targetMemberId = viewModel.mutedMembers[indexPath.row].getId()
        vc.targetMemberName = viewModel.mutedMembers[indexPath.row].getUsername()
        vc.targetMemberProfileImageUrl = viewModel.mutedMembers[indexPath.row].getProfileImageUrl()
        vc.delegate = self
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true)
    }
}




extension KlatRestrictedListViewController: KlatChildViewControllerDelegate {
    
    func childViewControllerDidDismiss() {
        viewModel.requestMutedMembers()
    }
    
}
    
