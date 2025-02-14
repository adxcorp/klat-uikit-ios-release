
import Foundation
import TalkPlus

class KlatRestrictedListViewModel: KlatBaseViewModel {
    
    private var channel:TPChannel?
    
    var didMutedMemberUpdated:(() -> Void)?
    var didChatChannelChanged:((TPChannel?) -> Void)?
    var mutedMembers:[TPMember] = []
    
    init(targetChannel: TPChannel?) {
        super.init()
        self.channel = targetChannel
    }
    
    override func klatReactionUpdated(channel:TPChannel, message:TPMessage) {}
    override func klatMessageReceived(channel: TPChannel, messages: [TPMessage]) {}
    override func klatMessageDeleted(channel: TPChannel, messages: [TPMessage]) {}
    override func newKlatChannelAdded(channels: [TPChannel]) {}
    override func klatChannelRemoved(channel: TPChannel) {}
    override func klatMemberUnbanned(channel:TPChannel, members:[TPMember]) {}
    override func klatMemberBanned(channel:TPChannel, members:[TPMember]) {}
    override func klatMemberLeft(channel: TPChannel, members: [TPMember]) {}
    override func klatMemberAdded(channel: TPChannel, members: [TPMember]) {}
    override func klatChannelChanged(channel: TPChannel) {}
    override func klatMoveToPrivateChannel(channel:TPChannel) {}
    
    func requestMutedMembers() {
        mutedMembers.removeAll()
        if isChannelOwner(channel: self.channel) {
            requestMutedMembers(lastMember: nil, memberList: nil)
            return
        }
        requestMutedPeers(lastMember: nil, memberList: nil)
    }
        
    private func requestMutedPeers(lastMember:TPMember? = nil, memberList:[TPMember]?) {
        Task {
            var memberArray:[TPMember] = memberList ?? []
            guard let channel = self.channel else { return }
            let result = await KlatChatAPIs.shared.getMutedPeers(channel: channel, lastMember: lastMember)
            if let members = result.2 { memberArray.append(contentsOf: members) }
            if result.0 == true, result.3 == true { // hasNext
                requestMutedPeers(lastMember: result.2?.last, memberList: memberArray)
                return
            }
            mutedMembers.append(contentsOf: memberArray)
            await MainActor.run {
                didMutedMemberUpdated?()
            }
        }
    }
    
    private func requestMutedMembers(lastMember:TPMember? = nil, memberList:[TPMember]?) {
        Task {
            var memberArray:[TPMember] = memberList ?? []
            guard let channel = self.channel else { return }
            let result = await KlatChatAPIs.shared.getMutedMembers(channel: channel, lastMember: lastMember)
            if let members = result.2 { memberArray.append(contentsOf: members) }
            if result.0 == true, result.3 == true { // hasNext
                requestMutedMembers(lastMember: result.2?.last, memberList: memberArray)
                return
            }
            mutedMembers.append(contentsOf: memberArray)
            await MainActor.run {
                didMutedMemberUpdated?()
            }
        }
    }
}
