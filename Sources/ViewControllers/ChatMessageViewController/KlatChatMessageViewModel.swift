
import Foundation
import TalkPlus

open class KlatChatMessageViewModel: KlatBaseViewModel {
    
    var newMessageReceived:(([TPMessage]) -> Void)?
    var moreMessageReceived:(() -> Void)?
    var messageDeleted:(([TPMessage], [Int]) -> Void)?
    var channelDataUpdated:((TPChannel, Int) -> Void)?
    var didChannelLeftOrDeleted: (() -> Void)?
    var reactionUpdated:((TPMessage, Int) -> Void)?
    
    var messages:[TPMessage] = []
    var targetChannel:TPChannel?
    
    init(targetChannel: TPChannel?) {
        super.init()
        self.targetChannel = targetChannel
    }
    
    func markAsRead() {
        Task {
            guard let chatChannel = targetChannel else { return }
            guard chatChannel.getUnreadCount() > 0 else { return }
            _ = await KlatChatAPIs.shared.markAsRead(channel: chatChannel)
        }
    }
    
    func isMessageAtLast(message:TPMessage?) -> Bool {
        guard let message = message else { return false }
        let index = self.messages.firstIndex { $0.getId() == message.getId() }
        return index == messages.count - 1
    }
    
    override func klatMessageReceived(channel: TPChannel, messages: [TPMessage]) {
        guard let chatChannel = targetChannel else { return }
        guard chatChannel.getId() == channel.getId() else { return }
        self.messages.append(contentsOf: messages.reversed())
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            newMessageReceived?(messages.reversed())
        }
    }
    
    override func klatMessageDeleted(channel: TPChannel, messages: [TPMessage]) {
        guard let chatChannel = targetChannel else { return }
        guard chatChannel.getId() == channel.getId() else { return }
        var removedIndexes:[Int] = []
        for chatMessage in messages {
            let index = self.messages.firstIndex { $0.getId() == chatMessage.getId() }
            if index != nil {
                removedIndexes.append(index!)
                klatPrint("removed index, \(String(describing: index))")
                self.messages.remove(at: index!)
            }
        }
        guard removedIndexes.count > 0 else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            messageDeleted?(self.messages, removedIndexes)
        }
    }
    
    override func klatChannelChanged(channel: TPChannel) {
        guard let chatChannel = targetChannel else { return }
        guard chatChannel.getId() == channel.getId() else { return }
        let index = channels.firstIndex { $0.getId() == channel.getId() }
        targetChannel = channel
        guard let indexInArray = index else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            channelDataUpdated?(channel, indexInArray)
        }
    }
    override func klatMemberAdded(channel: TPChannel, members: [TPMember]) {
        guard let chatChannel = targetChannel else { return }
        guard chatChannel.getId() == channel.getId() else { return }
        targetChannel = channel
    }
    override func newKlatChannelAdded(channels: [TPChannel]) {
        
    }
    override func klatChannelRemoved(channel: TPChannel) {
        guard self.targetChannel?.getId() == channel.getId() else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            didChannelLeftOrDeleted?()
        }
    }
    override func klatMemberLeft(channel: TPChannel, members: [TPMember]) {
        guard let chatChannel = targetChannel else { return }
        guard chatChannel.getId() == channel.getId() else { return }
        targetChannel = channel
        if isMemberToChannel(channel: channel) { return }
        DispatchQueue.main.async { [weak self] in
            self?.didChannelLeftOrDeleted?()
        }
    }
    override func klatMemberBanned(channel:TPChannel, members:[TPMember]) {
        guard let chatChannel = targetChannel else { return }
        guard chatChannel.getId() == channel.getId() else { return }
        targetChannel = channel
        if isMemberToChannel(channel: channel) { return }
        DispatchQueue.main.async { [weak self] in
            self?.didChannelLeftOrDeleted?()
        }
    }
    override func klatMemberUnbanned(channel:TPChannel, members:[TPMember]) {}
    override func klatMoveToPrivateChannel(channel:TPChannel) {}
    
    override func klatReactionUpdated(channel:TPChannel, message:TPMessage) {
        guard let chatChannel = targetChannel else { return }
        guard chatChannel.getId() == channel.getId() else { return }
        let index = self.messages.firstIndex { $0.getId() == message.getId() }
        guard let index = index else { return }
        self.messages[index] = message
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            reactionUpdated?(message, index)
        }
    }
}


extension KlatChatMessageViewModel {

    func addEmojiToMessage(message:TPMessage?, emoji:String) async throws {
        guard let message = message, emoji.isEmpty == false else {
            throw KlatError.invalidMessage
        }
        let isSameEmoji = isSameEmoji(message: message, targetEmoji: emoji)
        do {
            try await removeEmojiFromMessage(message: message, emoji: emoji)
            guard isSameEmoji == false else { return }
            let result = await KlatChatAPIs.shared.addMessageReaction(message: message, reaction: emoji)
            if let error = result.1 { throw error }
        } catch {
            throw error
        }
    }
    
    private func isSameEmoji(message:TPMessage?, targetEmoji:String) -> Bool {
        guard let message = message else { return false }
        guard let reactions = message.getReactions() as? [String:Any] else { return false }
        guard let loginUserId = KlatChatAPIs.shared.loginUser?.getId() else { return false }
        if reactions[targetEmoji] == nil { return false }
        let users = reactions[targetEmoji] as? [String]
        let emojiExist = (users?.filter { $0 == loginUserId }.count != 0)
        if emojiExist {
            return true
        }
        return false
    }
    
    private func removeEmojiFromMessage(message:TPMessage?, emoji:String) async throws {
        guard let message = message else { return }
        guard let reactions = message.getReactions() as? [String:Any] else { return }
        guard let loginUserId = KlatChatAPIs.shared.loginUser?.getId() else { return }
        let emojis = await UITableView.getSupportedEmojiList()
        for emoji in emojis {
            if reactions[emoji] == nil { continue }
            let users = reactions[emoji] as? [String]
            let emojiExist = (users?.filter { $0 == loginUserId }.count != 0)
            if emojiExist == false { continue }
            let result = await KlatChatAPIs.shared.removeMessageReaction(message: message, reaction: emoji)
            if let error = result.1 { throw error }
        }
    }
    
    func deleteMessage(message:TPMessage) async throws {
        guard let targetChannel = targetChannel else {
            throw KlatError.invalidChannel
        }
        let result = await KlatChatAPIs.shared.deleteMessage(channel: targetChannel, message: message)
        if let error = result.1 { throw error }
    }
    
    func sendMessage(params:TPMessageSendParams) async throws {
        let channelID = params.channel.getId() ?? ""
        let sendResult = await KlatChatAPIs.shared.sendMessage(params: params)
        if let error = sendResult.1 { throw error }
        guard sendResult.0 == true, channelID.count > 0 else { return }
        let getResult = await KlatChatAPIs.shared.getChannel(channelID: channelID)
        if let error = getResult.1 { throw error }
        if getResult.2 != nil {
            NotificationCenter.default.post(
                name: .klat_channelChanged,
                object: nil,
                userInfo: ["channel": getResult.2!])
        }
    }
    
    func getMoreChatMessages(targetChannel:TPChannel) async throws {
        guard let lastMessage = messages.first else { return }
        let params = TPMessageRetrievalParams(channel: targetChannel)!
        params.lastMessage = lastMessage
        let result = await KlatChatAPIs.shared.getMessages(params: params)
        if let error = result.1 { throw error }
        guard let messages = result.2, messages.count > 0 else {
            return
        }
        
        self.messages.insert(contentsOf: messages.reversed(), at: 0)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            moreMessageReceived?()
        }
    }
    
    func requestChatMessages(lastMessage:TPMessage?, targetChannel:TPChannel?) async throws {
        guard let targetChannel = targetChannel else {
            throw KlatError.invalidChannel
        }
        let params = TPMessageRetrievalParams(channel: targetChannel)!
        params.lastMessage = lastMessage
        let result = await KlatChatAPIs.shared.getMessages(params: params)
        if let error = result.1 { throw error }
        guard let messages = result.2, messages.count > 0 else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            klatMessageReceived(channel: targetChannel, messages: messages)
        }
    }
}
