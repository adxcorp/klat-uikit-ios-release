import UIKit
import TalkPlus

class KlatSearchChannelViewController: KlatBaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var viewModel:KlatSearchChannelViewModel!
    private var chatChannelCount = 0
    private var keywordText = ""
    
    var chatChannels:[TPChannel] = []
    var chatChannelSelected:((TPChannel) -> Void)?
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupNavigationItem()
        setupChannelListCell()
        setupViewModel()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        klatPrint(String(describing: type(of: self)), #function)
    }
    
    deinit {
        klatPrint(String(describing: type(of: self)), #function)
    }
    
    private func setupViewModel() {
        viewModel = KlatSearchChannelViewModel()
    }
    
    private func setupNavigationItem() {
        navigationItem.leftBarButtonItem = self.leftBarButton
        navigationItem.titleView = searchBar
    }

    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "채널 검색..."
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
        return searchBar
    }()
    
    private lazy var leftBarButton: UIBarButtonItem = {
        let backButton = UIButton()
        backButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        let backImage = UIImage(named: "KlatBack", in: Bundle(for: type(of: self)), compatibleWith:nil)
        backButton.setImage(backImage, for: .normal)
        backButton.addTarget(self, action: #selector(backButtonClicked), for: .touchUpInside)
        return UIBarButtonItem(customView: backButton)
    }()
    
    @objc func backButtonClicked() {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func setupChannelListCell() {
        tableView.dataSource = self
        tableView.delegate = self
        let tableViewCellId = String(describing: KlatChannelListTableViewCell.self)
        let nibName = UINib(nibName: tableViewCellId, bundle: Bundle(for: type(of: self)))
        tableView.register(nibName, forCellReuseIdentifier: tableViewCellId)
    }
    
    public func filterChatChannel(_ keyword:String) {
        self.keywordText = keyword
        
        guard keyword.count > 0 else {
            tableView.restore()
            return
        }
        
        let filterChannels = viewModel.channels.filter { channel in
            let channelName = channel.getName() ?? ""
            return channelName.lowercased().contains(keyword.lowercased())
        }
        
        if filterChannels.count == 0 {
            let image = UIImage(named: "KlatNoSearchResult", in: Bundle(for: type(of: self)), compatibleWith:nil)!
            tableView.setEmptyView(image: image, message: "검색 결과가 없습니다.")
        }
        
        chatChannels = filterChannels
        chatChannelCount = filterChannels.count
        tableView.reloadData()
    }
}

// MARK: - UISearchBarDelegate
extension KlatSearchChannelViewController: UISearchBarDelegate {
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let keyword = searchBar.searchTextField.text ?? ""
        searchBar.resignFirstResponder()
        filterChatChannel(keyword)
    }
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            tableView.restore()
            chatChannelCount = 0
            tableView.reloadData()
            return
        }
        filterChatChannel(searchBar.searchTextField.text ?? "")
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension KlatSearchChannelViewController: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatChannelCount
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = "KlatChannelListTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? KlatChannelListTableViewCell else {
            return UITableViewCell()
        }
        let chatChannel = chatChannels[indexPath.row]
        cell.configure(chatChannel: chatChannel, tableView: tableView, indexPath: indexPath)
        cell.changeKeywordColorInChannelName(keyword: self.keywordText)
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.navigationController?.popViewController(animated: true)
        let selectedChannel = chatChannels[indexPath.row]
        chatChannelSelected?(selectedChannel)
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
}
