
import Foundation
import TalkPlus

func klatPrint(_ items: Any..., separator: String = " ", terminator: String = "\n") {
#if DEBUG
    Swift.print(items.map { "\($0)" }.joined(separator: separator), terminator: terminator)
#else
#endif
}

protocol KlatViewModelProtocol {
    func setupViewModel()
}

protocol KlatEventReceivable {
    func newKlatChannelAdded(channels:[TPChannel])
    func klatChannelRemoved(channel:TPChannel)
    func klatChannelChanged(channel:TPChannel)
    func klatMessageReceived(channel:TPChannel, messages:[TPMessage])
    func klatMessageDeleted(channel:TPChannel, messages:[TPMessage])
    func klatMemberLeft(channel:TPChannel, members:[TPMember])
    func klatMemberAdded(channel:TPChannel, members:[TPMember])
    func klatMemberBanned(channel:TPChannel, members:[TPMember])
    func klatMemberUnbanned(channel:TPChannel, members:[TPMember])
    func klatReactionUpdated(channel:TPChannel, message:TPMessage)
    func klatMoveToPrivateChannel(channel:TPChannel)
}

open class KlatBaseViewModel: KlatViewModelProtocol, KlatEventReceivable {
    
    var channels:[TPChannel] {
        get {
            return KlatBaseViewModel.chatChannelsArray
        }
    }
    
    static private var chatChannelsArray:[TPChannel] = []
    static private var chatChannelsDictionary:[String:TPChannel] = [:] {
        didSet {
            var array = Array(KlatBaseViewModel.chatChannelsDictionary.values)
            // excludes super channels
            array = array.filter { $0.getType().contains("super_") == false }
            KlatBaseViewModel.chatChannelsArray = array
            KlatBaseViewModel.chatChannelsArray = array.sorted {
                guard let first = $0.getLastMessage()?.getCreatedAt() else { return false }
                guard let second = $1.getLastMessage()?.getCreatedAt() else { return true }
                return first > second
            }
        }
    }
    
    init() {
        klatPrint(String(describing: type(of: self)), #function)
        addKlatObserver()
    }
    
    deinit {
        klatPrint(String(describing: type(of: self)), #function)
        NotificationCenter.default.removeObserver(self)
    }
    
    func findChatChannel(channelID:String) -> TPChannel? {
        return KlatBaseViewModel.chatChannelsDictionary[channelID]
    }
    
    func requestChatChannels(lastChannel:TPChannel?) async throws {
        
        var stopRepeat = false
        var lastChatChannel = lastChannel
        
        repeat {
            let result = await KlatChatAPIs.shared.getChannels(lastChannel: lastChatChannel)
            
            if let error = result.1 { throw error }
            
            stopRepeat = true
            
            guard let retrievedChannels = result.2 else { return }
            for channel in retrievedChannels {
                let channelID = channel.getId() ?? ""
                if channelID.count == 0 { continue }
                KlatBaseViewModel.chatChannelsDictionary[channelID] = channel
            }
            
            let hasMoreChannels = result.3
            if hasMoreChannels == true {
                stopRepeat = false
                lastChatChannel = retrievedChannels.last
            }
            
        } while(stopRepeat == false)
    }
    
    func getImageData(image:UIImage?, quality:CGFloat = 1.0) -> Data? {
        guard let image = image else { return nil}
        let compressionQuality: CGFloat = min(quality, 1.0) // 0.0: max compress, 1.0: original quality
        if let imageData = image.jpegData(compressionQuality: compressionQuality) {
            klatPrint("image size: \(imageData.count) bytes")
            return imageData
        }
        return nil
    }
    
    func getCompressedImage(image:UIImage?, quality:CGFloat = 1.0) -> UIImage? {
        guard let image = image else { return nil}
        let compressionQuality: CGFloat = min(quality, 1.0) // 0.0: max compress, 1.0: original quality
        if let imageData = image.jpegData(compressionQuality: compressionQuality) {
            klatPrint("image size: \(imageData.count) bytes")
            return UIImage(data: imageData)
        }
        return nil
    }
    
    func resizeImageToFit(screenSize: CGSize, image: UIImage?) -> UIImage? {
        guard let image = image else { return nil}
        let scale = min(screenSize.width / image.size.width, screenSize.height / image.size.height)
        let newSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
    
    /// KlatViewModelProtocol
    func setupViewModel() { fatalError("'\(#function)' must be overridden by subclasses") }
    
    /// KlatEventReceivable
    func newKlatChannelAdded(channels: [TPChannel]) { fatalError("'\(#function)' must be overridden by subclasses") }
    func klatChannelRemoved(channel: TPChannel) { fatalError("'\(#function)' must be overridden by subclasses") }
    func klatChannelChanged(channel: TPChannel) { fatalError("'\(#function)' must be overridden by subclasses") }
    func klatMessageReceived(channel: TPChannel, messages: [TPMessage]) { fatalError("'\(#function)' must be overridden by subclasses") }
    func klatMessageDeleted(channel: TPChannel, messages: [TPMessage]) { fatalError("'\(#function)' must be overridden by subclasses") }
    func klatMemberLeft(channel: TPChannel, members: [TPMember]) { fatalError("'\(#function)' must be overridden by subclasses") }
    func klatMemberAdded(channel: TPChannel, members: [TPMember]) { fatalError("'\(#function)' must be overridden by subclasses") }
    func klatMemberBanned(channel:TPChannel, members:[TPMember]) { fatalError("'\(#function)' must be overridden by subclasses") }
    func klatMemberUnbanned(channel:TPChannel, members:[TPMember]) { fatalError("'\(#function)' must be overridden by subclasses") }
    func klatReactionUpdated(channel:TPChannel, message:TPMessage) { fatalError("'\(#function)' must be overridden by subclasses") }
    func klatMoveToPrivateChannel(channel:TPChannel) { fatalError("'\(#function)' must be overridden by subclasses") }
    
    func addKlatObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMoveToPrivateChannel(_:)),
            name: .klat_moveToOneToOneChannel,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNewChannelAdded(_:)),
            name: .klat_channelAdded,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleChannelRemoved(_:)),
            name: .klat_channelRemoved,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleChannelChanged(_:)),
            name: .klat_channelChanged,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMessageReceived(_:)),
            name: .klat_messageReceived,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMessageDeleted(_:)),
            name: .klat_messageDeleted,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMemberLeft(_:)),
            name: .klat_memberLeft,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMemberAdded(_:)),
            name: .klat_memberAdded,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMemberBanned(_:)),
            name: .klat_memberBanned,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMemberUnbanned(_:)),
            name: .klat_memberUnbanned,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleReactionUpdated(_:)),
            name: .klat_reactionUpdated,
            object: nil
        )
    }
    
    func isMyMessage(message:TPMessage) -> Bool {
        guard let user = KlatChatAPIs.shared.loginUser else { return false }
        let loginUserId = user.getId() ?? ""
        let messageSenderId = message.getUserId() ?? ""
        guard loginUserId.isEmpty == false, messageSenderId.isEmpty == false else { return false }
        return loginUserId == messageSenderId
    }
    
    func removeChatChannel(chhanelID:String) {
        KlatBaseViewModel.chatChannelsDictionary.removeValue(forKey: chhanelID)
    }
    
    func updateChatChannel(channel:TPChannel?) {
        guard let channel = channel else { return }
        guard let channelID = channel.getId(), channelID.isEmpty == false else { return }
        KlatBaseViewModel.chatChannelsDictionary[channelID] = channel
        NotificationCenter.default.post(
            name: .klat_channelChanged,
            object: nil,
            userInfo: ["channel": channel]
        )
    }
    
    func isMemberToChannel(channel:TPChannel?) -> Bool {
        guard let userId = KlatChatAPIs.shared.loginUser?.getId() else { return false }
        if let members = channel?.getMembers() as? [TPUser] {
            let membersIDs = members.map { $0.getId() }
            return membersIDs.contains(userId)
        }
        return false
    }
    
    func isMemberToChannel(userId:String?, channel:TPChannel?) -> Bool {
        guard userId?.count ?? 0 > 0 else { return false }
        if let members = channel?.getMembers() as? [TPUser] {
            let membersIDs = members.map { $0.getId() }
            return membersIDs.contains(userId)
        }
        return false
    }
    
    func isChannelOwner(channel:TPChannel?) -> Bool {
        guard let channel = channel else { return false }
        guard let userId = KlatChatAPIs.shared.loginUser?.getId() else { return false }
        return userId == channel.getOwnerId()
    }
    
    func isLoginUser(member:TPMember?) -> Bool {
        guard let member = member else { return false }
        guard let userId = KlatChatAPIs.shared.loginUser?.getId() else { return false }
        return userId == member.getId()
    }
}


extension KlatBaseViewModel {
    
    @objc private func handleMoveToPrivateChannel(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let channel = userInfo["channel"] as? TPChannel else { return }
        guard let channelID = channel.getId(), channelID.isEmpty == false else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            klatMoveToPrivateChannel(channel: channel)
        }
    }
    
    @objc private func handleNewChannelAdded(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let channel = userInfo["channel"] as? TPChannel else { return }
        guard let channelID = channel.getId(), channelID.isEmpty == false else { return }
        KlatBaseViewModel.chatChannelsDictionary[channelID] = channel
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            newKlatChannelAdded(channels: [channel])
        }
    }
    
    @objc private func handleChannelRemoved(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let channel = userInfo["channel"] as? TPChannel else { return }
        guard let channelID = channel.getId(), channelID.isEmpty == false else { return }
        removeChatChannel(chhanelID: channelID)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            klatChannelRemoved(channel: channel)
        }
    }
    
    @objc private func handleChannelChanged(_ notification: Notification) {
        updateChannel(notification) { [weak self] channel in
            guard let self = self, let channel = channel else { return }
            klatChannelChanged(channel: channel)
        }
    }
    
    @objc private func handleMessageReceived(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let channel = userInfo["channel"] as? TPChannel else { return }
        guard let message = userInfo["message"] as? TPMessage else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            klatMessageReceived(channel: channel, messages: [message])
        }
    }
    
    @objc private func handleMessageDeleted(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let channel = userInfo["channel"] as? TPChannel else { return }
        guard let message = userInfo["message"] as? TPMessage else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            klatMessageDeleted(channel: channel, messages: [message])
        }
    }
    
    @objc public func handleMemberLeft(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let members = userInfo["members"] as? [TPMember] else { return }
        updateChannel(notification) { [weak self] channel in
            guard let self = self, let channel = channel else { return }
            klatMemberLeft(channel: channel, members: members)
        }
    }
    
    @objc private func handleMemberAdded(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let members = userInfo["members"] as? [TPMember] else { return }
        updateChannel(notification) { [weak self] channel in
            guard let self = self, let channel = channel else { return }
            klatMemberAdded(channel: channel, members: members)
        }
    }
    
    @objc private func handleMemberBanned(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let members = userInfo["users"] as? [TPMember] else { return }
        updateChannel(notification) { [weak self] channel in
            guard let self = self, let channel = channel else { return }
            klatMemberBanned(channel: channel, members: members)
        }
    }
    
    @objc private func handleMemberUnbanned(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let members = userInfo["users"] as? [TPMember] else { return }
        updateChannel(notification) { [weak self] channel in
            guard let self = self, let channel = channel else { return }
            klatMemberUnbanned(channel: channel, members: members)
        }
    }
    
    @objc private func handleReactionUpdated(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let channel = userInfo["channel"] as? TPChannel else { return }
        guard let message = userInfo["message"] as? TPMessage else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            klatReactionUpdated(channel: channel, message: message)
        }
    }
    
    private func updateChannel(_ notification: Notification, completion:@escaping ((TPChannel?)->Void)) {
        guard let userInfo = notification.userInfo,
            let channel = userInfo["channel"] as? TPChannel,
            let channelID = channel.getId(), channelID.isEmpty == false else {
            DispatchQueue.main.async { completion(nil) }
            return
        }
        
        KlatBaseViewModel.chatChannelsDictionary[channelID] = channel
        
        if isMemberToChannel(channel: channel) == false {
            removeChatChannel(chhanelID: channel.getId())
        }
        
        DispatchQueue.main.async { completion(channel) }
    }
}
