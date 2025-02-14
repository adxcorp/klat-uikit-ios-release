
import UIKit

class KlatErrorViewController: KlatBaseViewController {

    var didTapRetry:(() -> Void)?
    var didTapClose:(() -> Void)?
    var error:Error?
    
    @IBOutlet weak var closeButton: UIButton! {
        didSet {
            closeButton.setTitle("", for: .normal)
        }
    }
    @IBOutlet weak var errorImageView: UIImageView!
    @IBOutlet weak var errorLabel: UILabel! {
        didSet {
            errorLabel.textAlignment = .center
        }
    }
    @IBOutlet weak var retryStackView: UIStackView! {
        didSet {
            retryStackView.layer.cornerRadius = 15
            retryStackView.layer.borderWidth = 2
            retryStackView.layer.borderColor = UIColor.Border.klatDefaultColor.cgColor
            retryStackView.layer.masksToBounds = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(retryTapped))
            retryStackView.addGestureRecognizer(tapGesture)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
        addSwipeGesture()
    }
    
    private func setupUI() {
        var errorMessage = "오류가 발생했습니다.\n다시 시도해주세요."
        if let error = error {
            errorMessage.append("\n\n(\(error.localizedDescription))")
        }
        errorLabel.text = errorMessage
    }
    
    @objc private func retryTapped() {
        self.dismiss(animated: true)
        didTapRetry?()
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true)
        didTapClose?()
    }
    
    private func addSwipeGesture() {
        let edgePanGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleEdgePanGesture(_:)))
        edgePanGesture.edges = .left
        self.view.addGestureRecognizer(edgePanGesture)
    }
    
    @objc private func handleEdgePanGesture(_ gesture: UISwipeGestureRecognizer) {
        guard gesture.state == .ended else { return }
        self.dismiss(animated: true, completion: nil)
        didTapClose?()
    }
    
}
