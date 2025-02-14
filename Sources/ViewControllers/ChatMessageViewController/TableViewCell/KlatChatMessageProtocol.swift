
import UIKit
import TalkPlus

protocol KlatChatMessageProtocol {
    
    var didImageViewTapped:((TPMessage?)->Void)? { get set}
    
    func updateUnreadCountLabel(channel:TPChannel, message:TPMessage)
        
    func configure(channel:TPChannel,
                   message:TPMessage,
                   otherMessages:(TPMessage?, TPMessage?),
                   tableView: UITableView,
                   indexPath:IndexPath)
}
