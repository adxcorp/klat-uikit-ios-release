
import UIKit
import TalkPlus

class KlatRestrictedListTableViewCell: UITableViewCell {

    @IBOutlet weak var memberProfileImage: UIImageView! {
        didSet {
            memberProfileImage.layer.cornerRadius = memberProfileImage.frame.width / 2
        }
    }
    
    @IBOutlet weak var memberNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configure(member:TPUser) {
        memberNameLabel.text = member.getUsername() ?? ""
        if let url = member.getProfileImageUrl() {
            UIImage.loadImage(from: url) { [weak self] image, _ in
                self?.memberProfileImage.image = image
            }
        }
    }
    
}
