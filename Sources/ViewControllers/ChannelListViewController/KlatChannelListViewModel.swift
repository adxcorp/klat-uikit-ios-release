
import Foundation
import TalkPlus

open class KlatChannelListViewModel: KlatBaseViewModel {
    
    var channelListUpdated:(() -> Void)?
    var moveToPrivateChannel:((TPChannel) -> Void)?
    
    override init() {
        super.init()
    }
    
    func requestChatChannels() async throws {
        do {
            try await requestChatChannels(lastChannel: nil)
        } catch {
            throw error
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.channelListUpdated?()
        }
    }
    
    func leaveChatChannel(channel:TPChannel?) async throws {
        guard let channel else { throw KlatError.invalidChannel }
        let result = await KlatChatAPIs.shared.leaveChannel(channel: channel)
        if let error = result.1 { throw error }
    }
    
    func markAsRead(channel:TPChannel?) async throws {
        guard let channel else { throw KlatError.invalidChannel }
        guard channel.getUnreadCount() > 0 else { return }
        let result = await KlatChatAPIs.shared.markAsRead(channel: channel)
        if let error = result.1 { throw error }
    }
    
    private func fireChannelListUpdatedEvent(channel: TPChannel) {
        channelListUpdated?()
    }
    
    override func newKlatChannelAdded(channels: [TPChannel]) {
        channelListUpdated?()
    }
    override func klatChannelRemoved(channel: TPChannel) {
        fireChannelListUpdatedEvent(channel: channel)
    }
    override func klatMemberAdded(channel: TPChannel, members: [TPMember]) {
        fireChannelListUpdatedEvent(channel: channel)
    }
    override func klatMemberLeft(channel: TPChannel, members: [TPMember]) {
        fireChannelListUpdatedEvent(channel: channel)
    }
    override func klatMemberBanned(channel:TPChannel, members:[TPMember]) {
        channelListUpdated?()
    }
    override func klatChannelChanged(channel: TPChannel) {
        fireChannelListUpdatedEvent(channel: channel)
    }
    
    override func klatMessageReceived(channel: TPChannel, messages: [TPMessage]) {}
    override func klatMessageDeleted(channel: TPChannel, messages: [TPMessage]) {}
    override func klatReactionUpdated(channel:TPChannel, message:TPMessage) {}
    override func klatMemberUnbanned(channel:TPChannel, members:[TPMember]) {}
    override func klatMoveToPrivateChannel(channel:TPChannel) {
        moveToPrivateChannel?(channel)
    }
    
}
