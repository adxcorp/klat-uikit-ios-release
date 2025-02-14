
import UIKit
import TalkPlus

class KlatImageViewerViewController: KlatBaseViewController {
    
    weak var chatMessage:TPMessage?
    weak var rootViewController:UIViewController?
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.delegate = self
            scrollView.zoomScale = 1.0
            scrollView.minimumZoomScale = 1.0
            scrollView.maximumZoomScale = 3.0
            scrollView.showsVerticalScrollIndicator = false
            scrollView.showsHorizontalScrollIndicator = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupTitle()
        setupImage()
        setupNavigationBarAndItem()
        addSwipeGesture()
        addDoubleTappGesture()
    }
    
    private func setupImage() {
        guard let message = chatMessage else { return }
        guard let imageUrl = message.getFileUrl(), imageUrl.count > 0 else { return }
        imageView.contentMode = .scaleAspectFit
        UIImage.loadImage(from: imageUrl) { [weak self] image, _ in
            guard let image = image else { return }
            self?.imageView.image = image
        }
    }
    
    private func setupTitle() {
        guard let message = chatMessage else { return }
        // UserName Label
        let userName = message.getUsername()
        let nameLabel = UILabel()
        nameLabel.text = userName
        nameLabel.font = .systemFont(ofSize: 16)
        nameLabel.textAlignment = .center
        nameLabel.textColor = UIColor.Label.klatTextWhiteColor
        // Time Label
        let date = Date(milliseconds: message.getCreatedAt())
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy. MM.dd. HH:mm"
        let formattedDate = formatter.string(from: date)
        let timeLabel = UILabel()
        timeLabel.text = formattedDate
        timeLabel.textAlignment = .center
        timeLabel.font = .systemFont(ofSize: 13)
        timeLabel.textColor = UIColor.Label.klatTextGrayColor3
        // StackView
        let stackView = UIStackView(arrangedSubviews: [nameLabel, timeLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 1
        
        navigationItem.titleView = stackView
    }
    
    private func setupNavigationBarAndItem() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.barTintColor = .clear
        navigationItem.leftBarButtonItem = leftBarButton
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    private lazy var leftBarButton: UIBarButtonItem = {
        let backButton = UIButton()
        backButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        let buttonImage = UIImage(named: "KlatBackWithWhite", in: Bundle(for: type(of: self)), compatibleWith:nil)
        backButton.setImage(buttonImage, for: .normal)
        backButton.addTarget(self, action: #selector(backButtonClicked), for: .touchUpInside)
        return UIBarButtonItem(customView: backButton)
    }()
    
    private lazy var rightBarButton: UIBarButtonItem = {
        let downloadButton = UIButton()
        downloadButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        let buttonImage = UIImage(named: "KlatDownload", in: Bundle(for: type(of: self)), compatibleWith:nil)
        downloadButton.setImage(buttonImage, for: .normal)
        downloadButton.addTarget(self, action: #selector(downloadButtonClicked), for: .touchUpInside)
        return UIBarButtonItem(customView: downloadButton)
    }()
    
    private func addDoubleTappGesture() {
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTapGesture)
    }
    
    @objc func handleDoubleTap(_ sender: UITapGestureRecognizer) {
        scrollView.zoomScale = 1.0
    }
    
    private func addSwipeGesture() {
        let edgePanGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleEdgePanGesture(_:)))
        edgePanGesture.edges = .left
        self.view.addGestureRecognizer(edgePanGesture)
    }
    
    @objc private func handleEdgePanGesture(_ gesture: UISwipeGestureRecognizer) {
        guard gesture.state == .ended else { return }
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func backButtonClicked() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func downloadButtonClicked() {
        guard let image = imageView.image else { return }
        let message = "앨범에 사진 저장 권한이 필요합니다. 설정에서 권한을 허용해주세요."
        if #available(iOS 14, *) {
            checkPhotoLibraryPermission(accessLevel: .addOnly) { [weak self] hasRight in
                guard let self = self else { return }
                guard hasRight == true else {
                    showSettingsAlert(message: message)
                    return
                }
                writeImageDataToAlbum(image: image)
            }
        } else {
            checkPhotoLibraryPermission { [weak self] hasRight in
                guard let self = self else { return }
                guard hasRight == true else {
                    showSettingsAlert(message: message)
                    return
                }
                writeImageDataToAlbum(image: image)
            }
        }
    }
    
    private func writeImageDataToAlbum(image:UIImage) {
        let selector = #selector(saveImage(_:didFinishSavingWithError:contextInfo:))
        navigationItem.rightBarButtonItem?.isEnabled = false
        startActivityIndicator()
        UIImageWriteToSavedPhotosAlbum(image, self, selector, nil)
    }
    
    @objc func saveImage(_ image:UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        navigationItem.rightBarButtonItem?.isEnabled = true
        stopActivityIndicator()
        if let _ = error { return }
        showKlatToast("앨범에 저장되었습니다.")
    }
}

//MARK:- UIScrollViewDelegate
extension KlatImageViewerViewController:UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.zoomScale <= 1.0 { scrollView.zoomScale = 1.0 }
        if scrollView.zoomScale >= 3.0 { scrollView.zoomScale = 3.0 }
    }
}



