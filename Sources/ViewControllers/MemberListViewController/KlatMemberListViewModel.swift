
import Foundation
import TalkPlus

open class KlatMemberListViewModel: KlatBaseViewModel {
    
    private var channel:TPChannel?
    
    var members:[TPMember] = []
    
    var channelMemberUpdated:((TPChannel) -> Void)?
    
    init(targetChannel: TPChannel?) {
        super.init()
        self.channel = targetChannel
        if let chatChannel = targetChannel {
            channelMemberUpdate(channel: chatChannel)
        }
    }
    
    override func klatReactionUpdated(channel:TPChannel, message:TPMessage) {}
    override func klatMessageReceived(channel: TPChannel, messages: [TPMessage]) {}
    override func klatMessageDeleted(channel: TPChannel, messages: [TPMessage]) {}
    override func newKlatChannelAdded(channels: [TPChannel]) {}
    override func klatChannelRemoved(channel: TPChannel) {}
    override func klatMoveToPrivateChannel(channel:TPChannel) {}
    override func klatMemberUnbanned(channel:TPChannel, members:[TPMember]) {}
    
    override func klatMemberLeft(channel: TPChannel, members: [TPMember]) {
        channelMemberUpdate(channel: channel)
    }
    override func klatMemberAdded(channel: TPChannel, members: [TPMember]) {
        channelMemberUpdate(channel: channel)
    }
    override func klatMemberBanned(channel:TPChannel, members:[TPMember]) {
        channelMemberUpdate(channel: channel)
    }
    override func klatChannelChanged(channel: TPChannel) {
        channelMemberUpdate(channel: channel)
    }
    private func channelMemberUpdate(channel: TPChannel) {
        guard let chatChannel = self.channel else { return }
        guard chatChannel.getId() == channel.getId() else { return }
        guard var members = channel.getMembers() as? [TPMember] else { return }
        let loginUser = KlatChatAPIs.shared.loginUser
        if let index = members.firstIndex(where: { $0.getId() == loginUser?.getId()}), index != 0 {
            let member = members.remove(at: index)
            members.insert(member, at: 0)
        }
        self.members = members
        self.channel = channel
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            channelMemberUpdated?(channel)
        }
    }
}
