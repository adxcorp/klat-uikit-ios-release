
import Foundation
import TalkPlus

class KlatChannelActionViewModel: KlatBaseViewModel {

    var didChannelChanged: ((TPChannel) -> Void)?
    
    var channel:TPChannel?

    func deleteChatChannel() async throws {
        guard let channel else { return }
        let result = await KlatChatAPIs.shared.deleteChannel(channel: channel)
        if let error = result.1 { throw error }
    }
    
    func leaveChatChannel() async throws {
        guard let channel else { return }
        let result = await KlatChatAPIs.shared.leaveChannel(channel: channel)
        if let error = result.1 { throw error }
    }
    
    func freezeChatChannel() async throws {
        guard let channel else { return }
        let result = await KlatChatAPIs.shared.freezeChannel(channel: channel)
        if let error = result.1 { throw error }
    }
    
    func unfreezeChatChannel() async throws {
        guard let channel else { return }
        let result = await KlatChatAPIs.shared.unfreezeChannel(channel: channel)
        if let error = result.1 { throw error }
    }
    
    func enableChannelPushNotification() async throws {
        guard let channel else { return }
        let result = await KlatChatAPIs.shared.enableChannelPushNotification(channel: channel)
        if let error = result.1 { throw error }
        if let chatChannel = result.2 {
            updateChatChannel(channel: chatChannel)
        }
    }
    
    func disableChannelPushNotification() async throws {
        guard let channel else { return }
        let result = await KlatChatAPIs.shared.disableChannelPushNotification(channel: channel)
        if let error = result.1 { throw error }
        if let chatChannel = result.2 {
            updateChatChannel(channel: chatChannel)
        }
    }
    
    override func klatMoveToPrivateChannel(channel:TPChannel) {}
    override func klatReactionUpdated(channel:TPChannel, message:TPMessage) {}
    override func klatMessageReceived(channel: TPChannel, messages: [TPMessage]) {}
    override func klatMessageDeleted(channel: TPChannel, messages: [TPMessage]) {}
    override func newKlatChannelAdded(channels: [TPChannel]) {}
    override func klatMemberUnbanned(channel:TPChannel, members:[TPMember]) {}
    
    override func klatMemberAdded(channel: TPChannel, members: [TPMember]) {
        guard self.channel?.getId() == channel.getId() else { return }
        self.channel = channel
        DispatchQueue.main.async { [weak self] in self?.didChannelChanged?(channel) }
    }
    override func klatChannelRemoved(channel: TPChannel) {
        guard self.channel?.getId() == channel.getId() else { return }
        self.channel = channel
        if isMemberToChannel(channel: channel) {
            DispatchQueue.main.async { [weak self] in
                self?.didChannelChanged?(channel)
            }
        }
    }
    override func klatMemberLeft(channel: TPChannel, members: [TPMember]) {
        guard self.channel?.getId() == channel.getId() else { return }
        self.channel = channel
        if isMemberToChannel(channel: channel) {
            DispatchQueue.main.async { [weak self] in
                self?.didChannelChanged?(channel)
            }
        }
    }
    override func klatMemberBanned(channel:TPChannel, members:[TPMember]) {
        guard self.channel?.getId() == channel.getId() else { return }
        self.channel = channel
        if isMemberToChannel(channel: channel) {
            DispatchQueue.main.async { [weak self] in
                self?.didChannelChanged?(channel)
            }
        }
    }
    override func klatChannelChanged(channel: TPChannel) {
        guard self.channel?.getId() == channel.getId() else { return }
        self.channel = channel
        DispatchQueue.main.async { [weak self] in
            self?.didChannelChanged?(channel)
        }
    }
}
