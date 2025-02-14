
import Foundation
import TalkPlus

class KlatCreateChannelViewModel: KlatBaseViewModel {
    
    override func klatReactionUpdated(channel:TPChannel, message:TPMessage) {}
    override func newKlatChannelAdded(channels: [TPChannel]) {}
    override func klatMoveToPrivateChannel(channel:TPChannel) {}
    override func klatChannelRemoved(channel: TPChannel) {}
    override func klatMessageReceived(channel: TPChannel, messages: [TPMessage]) {}
    override func klatMessageDeleted(channel: TPChannel, messages: [TPMessage]) {}
    override func klatMemberLeft(channel: TPChannel, members: [TPMember]) {}
    override func klatMemberAdded(channel: TPChannel, members: [TPMember]) {}
    override func klatMemberBanned(channel:TPChannel, members:[TPMember]) {}
    override func klatMemberUnbanned(channel:TPChannel, members:[TPMember]) {}
    override func klatChannelChanged(channel: TPChannel) {}
    
    func createNewChatChannel(channelName:String,
                              maxMemberCount:Int,
                              image:UIImage?,
                              completion:((TPChannel?)->Void)?) async throws {
        let params = TPChannelCreateParams(channelType: .private)
        params?.channelName = channelName
        params?.maxMemberCount = maxMemberCount
        params?.image = image
        params?.hideMessagesBeforeJoin = false
        if let compressedImage = getCompressedImage(image: image) {
            params?.image = compressedImage
        }
        
        let result = await KlatChatAPIs.shared.createNewChannel(params: params!)
        if let error = result.1 { throw error }
        DispatchQueue.main.async { completion?(result.2) }
    }
    
}
