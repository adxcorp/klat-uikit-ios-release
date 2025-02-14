
import UIKit
import TalkPlus
//import KlatUIKit

struct KlatConstants {
    static let APP_ID = "KLAT_APP_ID"
    struct SignInKey {
        static let USER_ID = "KLAT_USER_ID"
        static let USER_NAME = "KLAT_NICK_NAME"
    }
}

class SignInViewController: UIViewController {
    
    @IBOutlet weak var userIdTextField: UITextField!
    @IBOutlet weak var nickNameTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
    }
    
    func setupUI() {
        self.title = "Sign In"
        userIdTextField.placeholder = "ENTER_USER_ID"
        if let userId = UserDefaults.standard.string(forKey: KlatConstants.SignInKey.USER_ID) {
            userIdTextField.text = userId
        }
        nickNameTextField.placeholder = "ENTER_USER_NAME"
        if let userName = UserDefaults.standard.string(forKey: KlatConstants.SignInKey.USER_NAME) {
            nickNameTextField.text = userName
        }
    }

    @IBAction func signInButtonClicked(_ sender: Any) {
        self.signIn()
    }
    
    func signIn() {
        
        let userId = userIdTextField.text ?? ""
        let nickName = nickNameTextField.text ?? ""
        
        guard !userId.isEmpty else {
            userIdTextField.becomeFirstResponder()
            return
        }
        
        guard !nickName.isEmpty else {
            nickNameTextField.becomeFirstResponder()
            return
        }
        
        /// Sign in for anonymous
        let signInParams = TPLoginParams(loginType: TPLoginType.anonymous, userId: userId)
        signInParams?.userName = nickName
        
        TalkPlus.sharedInstance()?.login(signInParams, success: { [weak self] tpUser in
            guard let self = self else { return }
            print("klat login succeeded. user name: \(tpUser?.getUsername() ?? "")")
            UserDefaults.standard.set(userId, forKey: KlatConstants.SignInKey.USER_ID)
            UserDefaults.standard.set(nickName, forKey: KlatConstants.SignInKey.USER_NAME)
            showChannelListViewController()
            //showChatMessageViewController(channelId: "<CHANNEL_ID>")
        }, failure: { [weak self] (errorCode, error) in
            self?.view.isUserInteractionEnabled = true
            print("klat login failed with error \(String(describing: error))")
        })
    }
    
    func signInWithToken() {
        let userId = userIdTextField.text ?? ""
        let nickName = nickNameTextField.text ?? ""
        
        guard !userId.isEmpty else {
            userIdTextField.becomeFirstResponder()
            return
        }
        
        guard !nickName.isEmpty else {
            nickNameTextField.becomeFirstResponder()
            return
        }
        
        /// Sign in with Token
        let signInParams = TPLoginParams(loginType: .token, userId: userId)
        signInParams?.userName = nickName
        signInParams?.loginToken = "<USER_TOKEN>"
        
        TalkPlus.sharedInstance()?.login(signInParams, success: { [weak self] tpUser in
            guard let self = self else { return }
            print("klat login succeeded. user name: \(tpUser?.getUsername() ?? "")")
            UserDefaults.standard.set(userId, forKey: KlatConstants.SignInKey.USER_ID)
            UserDefaults.standard.set(nickName, forKey: KlatConstants.SignInKey.USER_NAME)
            showChannelListViewController()
            //showChatMessageViewController(channelId: "<CHANNEL_ID>")
        }, failure: { [weak self] (errorCode, error) in
            self?.view.isUserInteractionEnabled = true
            print("klat login failed with error \(String(describing: error))")
        })
    }
    
    private func showChannelListViewController() {
        let bundle = Bundle(for: KlatChannelListViewController.self)
        let nibName = String(describing: KlatChannelListViewController.self)
        let klatUIKitVC = KlatChannelListViewController(nibName: nibName, bundle: bundle)
        showViewController(viewController: klatUIKitVC)
    }
    
    private func showChatMessageViewController(channelId:String) {
        Task {
            let result = await getChannel(channelID: channelId)
            guard let channel = result.2 else { return }
            let bundle = Bundle(for: KlatChatMessageViewController.self)
            let nibName = String(describing: KlatChatMessageViewController.self)
            let klatUIKitVC = KlatChatMessageViewController(nibName: nibName, bundle: bundle)
            klatUIKitVC.chatChannel = channel
            await MainActor.run {
                showViewController(viewController: klatUIKitVC)
            }
        }
    }
    
    private func showViewController(viewController:UIViewController) {
        //self.navigationController?.pushViewController(viewController, animated: true)
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let windowScene = scene.delegate as? UIWindowSceneDelegate,
           let window = windowScene.window
        {
            guard let window = window else { return }
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
                window.rootViewController = UINavigationController(rootViewController: viewController)
            }, completion: nil)
        }
    }
    
    private func getChannel(channelID:String) async -> (Bool, Error?, TPChannel?) {
        return await withCheckedContinuation { continuation in
            TalkPlus.sharedInstance()?.getChannel(channelID, success: { channel in
                continuation.resume(returning: (true, nil, channel))
            }, failure: { (errorCode, error) in
                continuation.resume(returning: (false, error, nil))
            })
        }
    }
}
