
import UIKit
import Photos
import AVFoundation
import TalkPlus

protocol KlatChildViewControllerDelegate: AnyObject {
    func childViewControllerDidDismiss()
}

open class KlatBaseViewController: UIViewController {
    
    var delegate:KlatChildViewControllerDelegate?
    
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    lazy private var picker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        return picker
    }()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    func handleKlatApiError(error:Error?, retryClosure:(() -> Void)?) {
        let bundle = Bundle(for: KlatErrorViewController.self)
        let nibName = String(describing: KlatErrorViewController.self)
        let vc = KlatErrorViewController(nibName: nibName, bundle: bundle)
        vc.modalPresentationStyle = .fullScreen
        vc.error = error
        vc.didTapRetry = { retryClosure?() }
        vc.didTapClose = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    func popToRootViewController() {
        guard let presentingViewController = self.presentingViewController as? UINavigationController else {return}
        presentingViewController.popToRootViewController(animated: false)
        self.dismiss(animated: true, completion: nil)
    }
    
    func showActionSheetForAlbumOrCamera() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "사진 선택하기", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            openAlbum()
        }))
        actionSheet.addAction(UIAlertAction(title: "촬영하기", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            openCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        
        // For iPad
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX,
                                                  y: self.view.bounds.midY,
                                                  width: 0,
                                                  height: 0)
            popoverController.permittedArrowDirections = []
        }
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func startActivityIndicator(completion:(()->Void)? = nil) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                completion?()
                return
            }
            activityIndicator.center = view.center
            activityIndicator.color = UIColor.Background.containerColor2
            //activityIndicator.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            completion?()
        }
    }
    
    func stopActivityIndicator(completion:(()->Void)? = nil) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                completion?()
                return
            }
            activityIndicator.stopAnimating()
            completion?()
        }
    }
}

extension KlatBaseViewController {
    
    func openAlbum() {
        
        let message = "사진 접근 권한이 필요합니다. 설정에서 권한을 허용해주세요."
        
        if #available(iOS 14, *) {
            checkPhotoLibraryPermission(accessLevel: .readWrite) { [weak self] hasRight in
                guard let self = self else { return }
                guard hasRight == true else {
                    showSettingsAlert(message: message)
                    return
                }
                showPhotoLibraryPicker()
            }
        } else {
            checkPhotoLibraryPermission { [weak self] hasRight in
                guard let self = self else { return }
                guard hasRight == true else {
                    showSettingsAlert(message: message)
                    return
                }
                showPhotoLibraryPicker()
            }
        }
    }
    
    private func showPhotoLibraryPicker() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            let alert = UIAlertController(title: "에러",
                                          message: "앨범 접근 불가",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    func openCamera() {
        checkCameraPermission { [weak self] hasRight in
            guard let self = self else { return }
            guard hasRight == true else {
                let message = "카메라 사용 권한이 필요합니다. 설정에서 권한을 허용해주세요."
                showSettingsAlert(message: message)
                return
            }
            
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                let alert = UIAlertController(title: "에러",
                                              message: "카메라 사용 불가",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
                return
            }
            
            picker.sourceType = .camera
            present(picker, animated: true, completion: nil)
        }
    }
    
    func checkCameraPermission(completion: @escaping (Bool) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async { completion(granted) }
            }
        case .authorized:
            DispatchQueue.main.async { completion(true) }
        case .denied, .restricted:
            DispatchQueue.main.async { completion(false) }
        default:
            DispatchQueue.main.async { completion(false) }
        }
    }
    
    @available(iOS 14, *)
    func checkPhotoLibraryPermission(accessLevel:PHAccessLevel, completion: ((Bool)-> Void)?) {
        let status = PHPhotoLibrary.authorizationStatus(for: accessLevel)
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: accessLevel) { newStatus in
                if newStatus == .authorized || newStatus == .limited {
                    DispatchQueue.main.async { completion?(true) }
                } else {
                    DispatchQueue.main.async { completion?(false) }
                }
            }
        case .authorized, .limited:
            DispatchQueue.main.async { completion?(true) }
        case .denied, .restricted:
            DispatchQueue.main.async { completion?(false) }
        default:
            DispatchQueue.main.async { completion?(false) }
        }
    }
    
    func checkPhotoLibraryPermission(completion: ((Bool)-> Void)?) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                if newStatus == .authorized {
                    DispatchQueue.main.async { completion?(true) }
                } else {
                    DispatchQueue.main.async { completion?(false) }
                }
            }
        case .authorized:
            DispatchQueue.main.async { completion?(true) }
        case .denied, .restricted:
            DispatchQueue.main.async { completion?(false) }
        default:
            DispatchQueue.main.async { completion?(false) }
        }
    }
    
    func showSettingsAlert(message:String) {
        /// Your app mya be killed if you go to settings and change privacy settings for your app like changing location services
        /// or camera permissions for the app.
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let alert = UIAlertController(
                title: "권한 필요",
                message: message,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "설정으로 이동", style: .default, handler: { _ in
                if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
                }
            }))
            present(alert, animated: true)
        }
    }
    
}

extension KlatBaseViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}

extension KlatBaseViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return navigationController?.viewControllers.count ?? 0 > 1
    }
}
