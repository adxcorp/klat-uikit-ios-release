
import UIKit
import TalkPlus

class KlatMemberListTableViewCell: UITableViewCell {

    @IBOutlet weak var adminView: UIView! {
        didSet {
            adminView.layer.cornerRadius = 4
        }
    }
    @IBOutlet weak var meView: UIView! {
        didSet {
            meView.layer.cornerRadius = 4
        }
    }
    @IBOutlet weak var memberProfileImage: UIImageView! {
        didSet {
            memberProfileImage.layer.cornerRadius = memberProfileImage.frame.width / 2
        }
    }
    
    @IBOutlet weak var memberNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        meView.isHidden = true
        adminView.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configure(channel:TPChannel?, member:TPMember) {
        memberNameLabel.text = member.getUsername() ?? ""
        if let url = member.getProfileImageUrl() {
            UIImage.loadImage(from: url) { [weak self] image, _ in
                self?.memberProfileImage.image = image
            }
        }
        adminView.isHidden = true
        if let ownerId = channel?.getOwnerId() {
            adminView.isHidden = !(ownerId == member.getId())
        }
        guard let user = KlatChatAPIs.shared.loginUser else {
            meView.isHidden = true
            return
        }
        meView.isHidden = !(user.getId() == member.getId())
    }
    
}
