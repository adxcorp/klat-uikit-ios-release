
import Foundation
import TalkPlus

open class KlatSearchChannelViewModel: KlatBaseViewModel {
    
    override init() {
        super.init()
    }
    
    override func klatReactionUpdated(channel:TPChannel, message:TPMessage) {}
    override func newKlatChannelAdded(channels: [TPChannel]) {}
    override func klatMoveToPrivateChannel(channel:TPChannel) {}
    override func klatChannelRemoved(channel: TPChannel) {}
    override func klatMessageReceived(channel: TPChannel, messages: [TPMessage]) {}
    override func klatMessageDeleted(channel: TPChannel, messages: [TPMessage]) {}
    override func klatMemberLeft(channel: TPChannel, members: [TPMember]) {}
    override func klatMemberAdded(channel: TPChannel, members: [TPMember]) {}
    override func klatMemberBanned(channel:TPChannel, members:[TPMember]) { }
    override func klatMemberUnbanned(channel:TPChannel, members:[TPMember]) { }
    override func klatChannelChanged(channel: TPChannel) { }
}
