
import Foundation
import TalkPlus

class KlatEditChannelViewModel : KlatBaseViewModel {
    
    private var channel:TPChannel?
    
    var didChannelUpdated:((TPChannel)->Void)?
    
    init(targetChannel: TPChannel?) {
        super.init()
        self.channel = targetChannel
    }
    
    func updateChatChannel(channelName:String, image:UIImage?) async throws {
        guard let channel = channel else { throw KlatError.invalidChannel }
        let params = TPChannelUpdateParams(channel: channel)!
        params.channelName = channelName
        params.image = image
        if let compressedImage = getCompressedImage(image: image, quality: 1.0) {
            params.image = compressedImage
        }
        let result = await KlatChatAPIs.shared.updateChannel(params: params)
        if let error = result.1 { throw error }
        guard let channel = result.2 else { return }
        self.channel = channel
        DispatchQueue.main.async { [weak self] in
            self?.didChannelUpdated?(channel)
        }
    }
    
    override func klatReactionUpdated(channel:TPChannel, message:TPMessage) {}
    override func newKlatChannelAdded(channels: [TPChannel]) {}
    override func klatChannelRemoved(channel: TPChannel) {}
    override func klatMessageReceived(channel: TPChannel, messages: [TPMessage]) {}
    override func klatMessageDeleted(channel: TPChannel, messages: [TPMessage]) {}
    override func klatMemberLeft(channel: TPChannel, members: [TPMember]) {}
    override func klatMemberAdded(channel: TPChannel, members: [TPMember]) {}
    override func klatMemberBanned(channel:TPChannel, members:[TPMember]) { }
    override func klatMemberUnbanned(channel:TPChannel, members:[TPMember]) { }
    override func klatChannelChanged(channel: TPChannel) {
        guard self.channel?.getId() == channel.getId() else { return }
        self.channel = channel
    }
    override func klatMoveToPrivateChannel(channel:TPChannel) {}
}
