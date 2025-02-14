
import TalkPlus
import Foundation

class KlatChatAPIs : NSObject {
    private static let chatAPI = TalkPlus.sharedInstance()!
    private let uuidString = NSUUID().uuidString
    static let shared = KlatChatAPIs()
    public var loginUser:TPUser?
    
    private func isAuthenticated() -> Bool {
        let isAuthenticated = TalkPlus.sharedInstance()?.isAuthenticated() ?? false
        if isAuthenticated == true {
            loginUser = TalkPlus.sharedInstance()?.getCurrentUser() ?? nil
        }
        return isAuthenticated
    }
    
    private override init(){
        super.init()
        _ = addChannelDelegate(taget: self)
    }
    
    private func addChannelDelegate(taget:TPChannelDelegate) -> Bool {
        guard isAuthenticated() == true else {
            print("addChannelDelegate failed (reason: not authenticated)")
            return false
        }
        let uniqueTag = self.uuidString
        TalkPlus.sharedInstance()?.removeChannelDelegate(uniqueTag)
        TalkPlus.sharedInstance()?.add(taget, tag: uniqueTag)
        return true
    }
    
    private func removeChannelDelegate() -> Bool {
        guard isAuthenticated() == true else { return false }
        let uniqueTag = self.uuidString
        TalkPlus.sharedInstance()?.removeChannelDelegate(uniqueTag)
        return true
    }
}

// MARK: - Message
extension KlatChatAPIs {
    
    /// Get Message
    func getMessage(params: TPMessageRetrievalParams) async -> (Bool, Error?, TPMessage?) {
        guard isAuthenticated() == true else { return (false, KlatError.loginRequired, nil) }
        return await withCheckedContinuation { continuation in
            TalkPlus.sharedInstance()?.getMessage(params, success: { message in
                continuation.resume(returning: (true, nil, message))
            }, failure: { (errorCode, error) in
                let klatError = KlatError.convert(errorCode: Int(errorCode) as Int, error: error)
                continuation.resume(returning: (false, klatError, nil))
            })
        }
    }
    
    /// Get Messages
    func getMessages(params: TPMessageRetrievalParams) async -> (Bool, Error?, [TPMessage]?, Bool?) {
        guard isAuthenticated() == true else { return (false, KlatError.loginRequired, nil, nil) }
        return await withCheckedContinuation { continuation in
            TalkPlus.sharedInstance()?.getMessages(params, success: { messages, hasNext in
                continuation.resume(returning: (true, nil, messages, hasNext))
            }, failure: { (errorCode, error) in
                let klatError = KlatError.convert(errorCode: Int(errorCode) as Int, error: error)
                continuation.resume(returning: (false, klatError, nil, nil))
            })
        }
    }
    
    /// Get File Messages
    func getFileMessages(params: TPMessageRetrievalParams) async -> (Bool, Error?, [TPMessage]?, Bool?) {
        guard isAuthenticated() == true else { return (false, KlatError.loginRequired, nil, nil) }
        return await withCheckedContinuation { continuation in
            TalkPlus.sharedInstance()?.getFileMessages(params, success: { messages, hasNext in
                continuation.resume(returning: (true, nil, messages, hasNext))
            }, failure: { (errorCode, error) in
                let klatError = KlatError.convert(errorCode: Int(errorCode) as Int, error: error)
                continuation.resume(returning: (false, klatError, nil, nil))
            })
        }
    }
    
    /// Send Message
    func sendMessage(params: TPMessageSendParams) async -> (Bool, Error?, TPMessage?) {
        guard isAuthenticated() == true else { return (false, KlatError.loginRequired, nil) }
        return await withCheckedContinuation { continuation in
            TalkPlus.sharedInstance()?.sendMessage(params, success: { [weak self] message in
                guard let self = self else {
                    continuation.resume(returning: (true, nil, message))
                    return
                }
                self.messageReceived(params.channel!, message: message!)
                continuation.resume(returning: (true, nil, message))
            }, failure: { (errorCode, error) in
                let klatError = KlatError.convert(errorCode: Int(errorCode) as Int, error: error)
                continuation.resume(returning: (false, klatError, nil))
            })
        }
    }
    
    /// Delete Message
    func deleteMessage(channel: TPChannel, message:TPMessage) async -> (Bool, Error?) {
        guard isAuthenticated() == true else { return (false, KlatError.loginRequired) }
        return await withCheckedContinuation { continuation in
            TalkPlus.sharedInstance()?.deleteMessage(channel,
                                                     message: message,
                                                     success: {
                continuation.resume(returning: (true, nil))
            }, failure: { (errorCode, error) in
                let klatError = KlatError.convert(errorCode: Int(errorCode) as Int, error: error)
                continuation.resume(returning: (false, klatError))
            })
        }
    }
    
    /// Add Message Reaction
    func addMessageReaction(message: TPMessage, reaction: String) async -> (Bool, Error?, TPMessage?) {
        guard isAuthenticated() == true else { return (false, KlatError.loginRequired, nil) }
        return await withCheckedContinuation { continuation in
            TalkPlus.sharedInstance()?.addMessageReaction(message,
                                                          reaction: reaction,
                                                          success: { aMessage in
                continuation.resume(returning: (true, nil, aMessage))
            }, failure: { (errorCode, error) in
                let klatError = KlatError.convert(errorCode: Int(errorCode) as Int, error: error)
                continuation.resume(returning: (false, klatError, nil))
            })
        }
    }
    
    /// Remove Message Reaction
    func removeMessageReaction(message: TPMessage, reaction: String) async -> (Bool, Error?, TPMessage?) {
        guard isAuthenticated() == true else { return (false, KlatError.loginRequired, nil) }
        return await withCheckedContinuation { continuation in
            TalkPlus.sharedInstance()?.removeMessageReaction(message,
                                                             reaction: reaction,
                                                             success: { aMessage in
                continuation.resume(returning: (true, nil, aMessage))
            }, failure: { (errorCode, error) in
                let klatError = KlatError.convert(errorCode: Int(errorCode) as Int, error: error)
                continuation.resume(returning: (false, klatError, nil))
            })
        }
    }
    
}

// MARK: - Channels
extension KlatChatAPIs {
    
    /// Creates new chat channel
    func createNewChannel(params:TPChannelCreateParams) async -> (Bool, Error?, TPChannel?) {
        guard isAuthenticated() == true else { return (false, KlatError.loginRequired, nil) }
        return await withCheckedContinuation { continuation in
            TalkPlus.sharedInstance()?.createChannel(params, success: { channel in
                continuation.resume(returning: (true, nil, channel))
            }, failure: { (errorCode, error) in
                let klatError = KlatError.convert(errorCode: Int(errorCode) as Int, error: error)
                continuation.resume(returning: (false, klatError, nil))
            })
        }
    }
    
    /// Get Chatting Channels (joined channels)
    func getChannels(lastChannel:TPChannel?) async -> (Bool, Error?, [TPChannel]?, Bool) {
        guard isAuthenticated() == true else { return (false, KlatError.loginRequired, nil, false) }
        return await withCheckedContinuation { continuation in
            TalkPlus.sharedInstance()?.getChannels(lastChannel, success: { tpChannels, hasNext in
                continuation.resume(returning: (true, nil, tpChannels, hasNext))
            }, failure: { (errorCode, error) in
                let klatError = KlatError.convert(errorCode: Int(errorCode) as Int, error: error)
                continuation.resume(returning: (false, klatError, nil, false))
            })
        }
    }
    
    /// Get Chatting Channel
    func getChannel(channelID:String) async -> (Bool, Error?, TPChannel?) {
        guard isAuthenticated() == true else { return (false, KlatError.loginRequired, nil) }
        return await withCheckedContinuation { continuation in
            TalkPlus.sharedInstance()?.getChannel(channelID, success: { channel in
                continuation.resume(returning: (true, nil, channel))
            }, failure: { (errorCode, error) in
                let klatError = KlatError.convert(errorCode: Int(errorCode) as Int, error: error)
                continuation.resume(returning: (false, klatError, nil))
            })
        }
    }
    
    /// Get Chatting Channels (public channels)
    func getPublicChannels(lastChannel:TPChannel?) async -> (Bool, Error?, [TPChannel]?, Bool) {
        guard isAuthenticated() == true else { return (false, KlatError.loginRequired, nil, false) }
        return await withCheckedContinuation { continuation in
            TalkPlus.sharedInstance()?.getPublicChannels(lastChannel, success: { tpChannels, hasNext in
                continuation.resume(returning: (true, nil, tpChannels, hasNext))
            }, failure: { (errorCode, error) in
                let klatError = KlatError.convert(errorCode: Int(errorCode) as Int, error: error)
                continuation.resume(returning: (false, klatError, nil, false))
            })
        }
    }
    
    /// Search Chatting Channels
    func searchChannels(params:TPChannelQueryParams) async -> (Bool, Error?, [TPChannel]?) {
        guard isAuthenticated() == true else { return (false, KlatError.loginRequired, nil) }
        return await withCheckedContinuation { continuation in
            TalkPlus.sharedInstance()?.searchChannels(params, success: { channels, hasNext in
                continuation.resume(returning: (true, nil, channels))
            }, failure: { (errorCode, error) in
                let klatError = KlatError.convert(errorCode: Int(errorCode) as Int, error: error)
                continuation.resume(returning: (false, klatError, nil))
            })
        }
    }
    
    /// Search Public Chatting Channels
    func searchPublicChannels(params:TPChannelQueryParams) async -> (Bool, Error?, [TPChannel]?) {
        guard isAuthenticated() == true else { return (false, KlatError.loginRequired, nil) }
        return await withCheckedContinuation { continuation in
            TalkPlus.sharedInstance()?.searchPublicChannels(params, success: { channels, hasNext in
                continuation.resume(returning: (true, nil, channels))
            }, failure: { (errorCode, error) in
                let klatError = KlatError.convert(errorCode: Int(errorCode) as Int, error: error)
                continuation.resume(returning: (false, klatError, nil))
            })
        }
    }
    
    /// Udpate Channel
    func updateChannel(params:TPChannelUpdateParams) async -> (Bool, Error?, TPChannel?) {
        guard isAuthenticated() == true else { return (false, KlatError.loginRequired, nil) }
        return await withCheckedContinuation { continuation in
            TalkPlus.sharedInstance()?.updateChannel(params, success: { channel in
                continuation.resume(returning: (true, nil, channel))
            }, failure: { (errorCode, error) in
                let klatError = KlatError.convert(errorCode: Int(errorCode) as Int, error: error)
                continuation.resume(returning: (false, klatError, nil))
            })
        }
    }
    
    /// Udpate Channel
    func updateChannel(channel:TPChannel,
                       channelName:String,
                       category:String,
                       subcategory:String,
                       imageUrl:String,
                       metaData:[AnyHashable:Any]?) async -> (Bool, Error?, TPChannel?) {
        let params = TPChannelUpdateParams(channel: channel)!
        params.channelName = channelName
        params.category = category
        params.subcategory = subcategory
        params.imageUrl = imageUrl
        params.metaData = metaData
        return await updateChannel(params: params)
    }
    
    /// Udpate Channel Member Information
    func updateChannelMemberInfo(channel:TPChannel,
                                 memberInfo:[AnyHashable:Any]) async -> (Bool, Error?, TPMember?) {
        guard isAuthenticated() == true else { return (false, KlatError.loginRequired, nil) }
        return await withCheckedContinuation { continuation in
            TalkPlus.sharedInstance()?.update(channel,
                                              memberInfo: memberInfo, success: { aMember in
                continuation.resume(returning: (true, nil, aMember))
            }, failure: { (errorCode, error) in
                let klatError = KlatError.convert(errorCode: Int(errorCode) as Int, error: error)
                continuation.resume(returning: (false, klatError, nil))
            })
        }
    }
    
    /// Udpate Channel Private Data
    func updateChannelPrivateData(channel:TPChannel,
                                  privateData:[AnyHashable:Any]) async -> (Bool, Error?, TPChannel?) {
        guard isAuthenticated() == true else { return (false, KlatError.loginRequired, nil) }
        return await withCheckedContinuation { continuation in
            TalkPlus.sharedInstance()?.update(channel,
                                              privateData: privateData,
                                              success: { aChannel in
                continuation.resume(returning: (true, nil, aChannel))
            }, failure: { (errorCode, error) in
                let klatError = KlatError.convert(errorCode: Int(errorCode) as Int, error: error)
                continuation.resume(returning: (false, klatError, nil))
            })
        }
    }
    
    /// Udpate Channel Private Tag
    func updateChannelPrivateTag(channel:TPChannel,
                                 privateTag:String) async -> (Bool, Error?, TPChannel?) {
        guard isAuthenticated() == true else { return (false, KlatError.loginRequired, nil) }
        return await withCheckedContinuation { continuation in
            TalkPlus.sharedInstance()?.update(channel,
                                              privateTag: privateTag,
                                              success: { aChannel in
                continuation.resume(returning: (true, nil, aChannel))
            }, failure: { (errorCode, error) in
                let klatError = KlatError.convert(errorCode: Int(errorCode) as Int, error: error)
                continuation.resume(returning: (false, klatError, nil))
            })
        }
    }
    
    /// Enable Channel Push Notification
    func enableChannelPushNotification(channel:TPChannel) async -> (Bool, Error?, TPChannel?)
    {
        guard isAuthenticated() == true else { return (false, KlatError.loginRequired, nil) }
        return await withCheckedContinuation { continuation in
            TalkPlus.sharedInstance()?.enableChannelPushNotification(channel, success: { channel in
                continuation.resume(returning: (true, nil, channel))
            }, failure: { (errorCode, error) in
                let klatError = KlatError.convert(errorCode: Int(errorCode) as Int, error: error)
                continuation.resume(returning: (false, klatError, nil))
            })
        }
    }
    
    /// Disable Channel Push Notification
    func disableChannelPushNotification(channel:TPChannel) async -> (Bool, Error?, TPChannel?)
    {
        guard isAuthenticated() == true else { return (false, KlatError.loginRequired, nil) }
        return await withCheckedContinuation { continuation in
            TalkPlus.sharedInstance()?.disableChannelPushNotification(channel, success: { channel in
                continuation.resume(returning: (true, nil, channel))
            }, failure: { (errorCode, error) in
                let klatError = KlatError.convert(errorCode: Int(errorCode) as Int, error: error)
                continuation.resume(returning: (false, klatError, nil))
            })
        }
    }
    
    /// Mark As Read To Specific Channel
    func markAsRead(channel:TPChannel) async -> (Bool, Error?, TPChannel?) {
        guard isAuthenticated() == true else { return (false, KlatError.loginRequired, nil) }
        return await withCheckedContinuation { continuation in
            TalkPlus.sharedInstance()?.mark(asRead: channel, success: { channel in
                continuation.resume(returning: (true, nil, channel))
            }, failure: { (errorCode, error) in
                let klatError = KlatError.convert(errorCode: Int(errorCode) as Int, error: error)
                continuation.resume(returning: (false, klatError, nil))
            })
        }
    }
    
    /// Mark As Read All Channels
    func markAsReadAll() async -> (Bool, Error?) {
        guard isAuthenticated() == true else { return (false, KlatError.loginRequired) }
        return await withCheckedContinuation { continuation in
            TalkPlus.sharedInstance()?.mark(asReadAllChannel: {
                continuation.resume(returning: (true, nil))
            }, failure: { (errorCode, error) in
                let klatError = KlatError.convert(errorCode: Int(errorCode) as Int, error: error)
                continuation.resume(returning: (false, klatError))
            })
        }
    }
    
}

// MARK: - User
extension KlatChatAPIs {
    
    func addMember(user:TPUser, channel:TPChannel) async -> (Bool, Error?, TPChannel?)
    {
        guard isAuthenticated() == true else { return (false, KlatError.loginRequired, nil) }
        return await withCheckedContinuation { continuation in
            TalkPlus.sharedInstance()?.addMember(to: channel,
                                                 userId: user.getId(), 
                                                 success: { channel in
                continuation.resume(returning: (true, nil, channel))
            }, failure: { (errorCode, error) in
                let klatError = KlatError.convert(errorCode: Int(errorCode) as Int, error: error)
                continuation.resume(returning: (false, klatError, nil))
            })
        }
    }
    
    func joinChannel(channelId:String, invitationCode:String) async -> (Bool, Error?, TPChannel?)
    {
        guard isAuthenticated() == true else { return (false, KlatError.loginRequired, nil) }
        return await withCheckedContinuation { continuation in
            TalkPlus.sharedInstance()?.joinChannel(channelId,
                                                   invitationCode: invitationCode,
                                                   success: { channel in
                continuation.resume(returning: (true, nil, channel))
            },failure: { (errorCode, error) in
                let klatError = KlatError.convert(errorCode: Int(errorCode) as Int, error: error)
                continuation.resume(returning: (false, klatError, nil))
            })
        }
    }
    
    /// Update UserProfile#1
    func updateUserProfile(userName:String,
                           profileUrl:String,
                           metaData:[AnyHashable : Any]) async -> (Bool, Error?, TPUser?)
    {
        guard isAuthenticated() == true else { return (false, KlatError.loginRequired, nil) }
        return await withCheckedContinuation { continuation in
            TalkPlus.sharedInstance()?.updateUserProfile(userName,
                                                         profileImageUrl: profileUrl,
                                                         metaData: metaData,
                                                         success: { tpUser in
                continuation.resume(returning: (true, nil, tpUser))
            }, failure: { (errorCode, error) in
                let klatError = KlatError.convert(errorCode: Int(errorCode) as Int, error: error)
                continuation.resume(returning: (false, klatError, nil))
            })
        }
    }
    
    /// Update UserProfile#2
    func updateUserProfile(userName:String,
                           profileImage:UIImage,
                           metaData:[AnyHashable : Any]) async -> (Bool, Error?, TPUser?)
    {
        guard isAuthenticated() == true else { return (false, KlatError.loginRequired, nil) }
        return await withCheckedContinuation { continuation in
            TalkPlus.sharedInstance()?.updateUserProfile(userName,
                                                         profileImage: profileImage,
                                                         metaData: metaData,
                                                         success: { tpUser in
                continuation.resume(returning: (true, nil, tpUser))
            }, failure: { (errorCode, error) in
                let klatError = KlatError.convert(errorCode: Int(errorCode) as Int, error: error)
                continuation.resume(returning: (false, klatError, nil))
            })
        }
    }

    /// Ban Member
    func banMember(channel:TPChannel, userId:String) async -> (Bool, Error?, TPChannel?)
    {
        guard isAuthenticated() == true else { return (false, KlatError.loginRequired, nil) }
        return await withCheckedContinuation { continuation in
            TalkPlus.sharedInstance()?.banMember(to: channel,
                                                 userId: userId,
                                                 success: { channel in
                continuation.resume(returning: (true, nil, channel))
            }, failure: { (errorCode, error) in
                let klatError = KlatError.convert(errorCode: Int(errorCode) as Int, error: error)
                continuation.resume(returning: (false, klatError, nil))
            })
        }
    }
    
    /// Unban Member
    func unbanMember(channel:TPChannel, userId:String) async -> (Bool, Error?, TPChannel?)
    {
        guard isAuthenticated() == true else { return (false, KlatError.loginRequired, nil) }
        return await withCheckedContinuation { continuation in
            TalkPlus.sharedInstance()?.unBanMember(to: channel,
                                                   userId: userId,
                                                   success: { channel in
                continuation.resume(returning: (true, nil, channel))
            }, failure: { (errorCode, error) in
                let klatError = KlatError.convert(errorCode: Int(errorCode) as Int, error: error)
                continuation.resume(returning: (false, klatError, nil))
            })
        }
    }
    
    /// Mute Peers
    func mutePeers(channel:TPChannel, userIds:[String]) async -> (Bool, Error?, [TPMember]?) 
    {
        guard isAuthenticated() == true else { return (false, KlatError.loginRequired, nil) }
        return await withCheckedContinuation { continuation in
            TalkPlus.sharedInstance()?.mutePeer(to: channel,
                                                userIds: userIds,
                                                expireInMinutes: 0,
                                                success: { channel, mutedMembers in
                continuation.resume(returning: (true, nil, mutedMembers))
            }, failure: { (errorCode, error) in
                let klatError = KlatError.convert(errorCode: Int(errorCode) as Int, error: error)
                continuation.resume(returning: (false, klatError, nil))
            })
        }
    }
    
    /// UnMute Peers
    func unmutePeers(channel:TPChannel, userIds:[String]) async -> (Bool, Error?, [TPMember]?) 
    {
        guard isAuthenticated() == true else { return (false, KlatError.loginRequired, nil) }
        return await withCheckedContinuation { continuation in
            TalkPlus.sharedInstance()?.unMutePeer(to: channel,
                                                userIds: userIds,
                                                success: { channel, unmutedMembers in
                continuation.resume(returning: (true, nil, unmutedMembers))
            }, failure: { (errorCode, error) in
                let klatError = KlatError.convert(errorCode: Int(errorCode) as Int, error: error)
                continuation.resume(returning: (false, klatError, nil))
            })
        }
    }
    
    /// Get Muted Peers
    func getMutedPeers(channel:TPChannel, lastMember:TPMember?) async -> (Bool, Error?, [TPMember]?, Bool) {
        guard isAuthenticated() == true else { return (false, KlatError.loginRequired, nil, false) }
        return await withCheckedContinuation { continuation in
            TalkPlus.sharedInstance()?.getMutedPeers(channel,
                                                     lastUser: lastMember,
                                                     success: { members, hasNext in
                continuation.resume(returning: (true, nil, members, hasNext))
            }, failure: { (errorCode, error) in
                let klatError = KlatError.convert(errorCode: Int(errorCode) as Int, error: error)
                continuation.resume(returning: (false, klatError, nil, false))
            })
        }
    }
    
    /// Get Muted Members
    func getMutedMembers(channel:TPChannel, lastMember:TPMember?) async -> (Bool, Error?, [TPMember]?, Bool) {
        guard isAuthenticated() == true else { return (false, KlatError.loginRequired, nil, false) }
        return await withCheckedContinuation { continuation in
            TalkPlus.sharedInstance()?.getMutedChannelMembers(channel,
                                                              lastUser: lastMember,
                                                              success: { members, hasNext in
                continuation.resume(returning: (true, nil, members, hasNext))
            }, failure: { (errorCode, error) in
                let klatError = KlatError.convert(errorCode: Int(errorCode) as Int, error: error)
                continuation.resume(returning: (false, klatError, nil, false))
            })
        }
    }
    
    /// Get Blocked Mebers
    func getBlockedMembers(lastMember:TPUser?) async -> (Bool, Error?, [TPUser]?, Bool)
    {
        guard isAuthenticated() == true else { return (false, KlatError.loginRequired, nil, false) }
        return await withCheckedContinuation { continuation in
            TalkPlus.sharedInstance()?.getBlockedUsers(lastMember,
                                                       success: { users, hasNext in
                continuation.resume(returning: (true, nil, users, hasNext))
            }, failure: { (errorCode, error) in
                let klatError = KlatError.convert(errorCode: Int(errorCode) as Int, error: error)
                continuation.resume(returning: (false, klatError, nil, false))
            })
        }
    }
    
    /// Block Member
    func blockMember(memberId:String) async -> (Bool, Error?)
    {
        guard isAuthenticated() == true else { return (false, KlatError.loginRequired) }
        return await withCheckedContinuation { continuation in
            TalkPlus.sharedInstance()?.blockUser(memberId, success: {
                continuation.resume(returning: (true, nil))
            }, failure: { (errorCode, error) in
                let klatError = KlatError.convert(errorCode: Int(errorCode) as Int, error: error)
                continuation.resume(returning: (false, klatError))
            })
        }
    }
    
    /// Unblock Member
    func unblockMember(memberId:String) async -> (Bool, Error?)
    {
        guard isAuthenticated() == true else { return (false, KlatError.loginRequired) }
        return await withCheckedContinuation { continuation in
            TalkPlus.sharedInstance()?.unblockUser(memberId, success: {
                continuation.resume(returning: (true, nil))
            }, failure: { (errorCode, error) in
                let klatError = KlatError.convert(errorCode: Int(errorCode) as Int, error: error)
                continuation.resume(returning: (false, klatError))
            })
        }
    }
    
    /// Mute Member
    func muteMember(channel:TPChannel, memberId:String) async -> (Bool, Error?, TPChannel?)
    {
        guard isAuthenticated() == true else { return (false, KlatError.loginRequired, nil) }
        return await withCheckedContinuation { continuation in
            TalkPlus.sharedInstance()?.muteMember(to: channel,
                                                  userId: memberId,
                                                  success: { channel in
                continuation.resume(returning: (true, nil, channel))
            }, failure: { (errorCode, error) in
                let klatError = KlatError.convert(errorCode: Int(errorCode) as Int, error: error)
                continuation.resume(returning: (true, klatError, nil))
            })
        }
    }
    
    /// Unmute Member
    func unmuteMember(channel:TPChannel, memberId:String) async -> (Bool, Error?, TPChannel?)
    {
        guard isAuthenticated() == true else { return (false, KlatError.loginRequired, nil) }
        return await withCheckedContinuation { continuation in
            TalkPlus.sharedInstance()?.unMuteMember(to: channel,
                                                    userId: memberId,
                                                    success: { channel in
                continuation.resume(returning: (true, nil, channel))
            }, failure: { (errorCode, error) in
                let klatError = KlatError.convert(errorCode: Int(errorCode) as Int, error: error)
                continuation.resume(returning: (false, klatError, nil))
            })
        }
    }
    
    
    /// enable Member Push Notification
    func enableMemberPushNotification() async -> (Bool, Error?, TPUser?)
    {
        guard isAuthenticated() == true else { return (false, KlatError.loginRequired, nil) }
        return await withCheckedContinuation { continuation in
            TalkPlus.sharedInstance()?.enablePushNotification({ user in
                continuation.resume(returning: (true, nil, user))
            }, failure: { (errorCode, error) in
                let klatError = KlatError.convert(errorCode: Int(errorCode) as Int, error: error)
                continuation.resume(returning: (false, klatError, nil))
            })
        }
    }
    
    /// disable  Member Push Notification
    func disableMemberPushNotification() async -> (Bool, Error?, TPUser?)
    {
        guard isAuthenticated() == true else { return (false, KlatError.loginRequired, nil) }
        return await withCheckedContinuation { continuation in
            TalkPlus.sharedInstance()?.disablePushNotification({ user in
                continuation.resume(returning: (true, nil, user))
            }, failure: { (errorCode, error) in
                let klatError = KlatError.convert(errorCode: Int(errorCode) as Int, error: error)
                continuation.resume(returning: (false, klatError, nil))
            })
        }
    }
    /// transfer chat channel ownership
    func transferChannelOwner(channel:TPChannel, userId:String) async -> (Bool, Error?, TPChannel?)
    {
        guard isAuthenticated() == true else { return (false, KlatError.loginRequired, nil) }
        return await withCheckedContinuation { continuation in
            TalkPlus.sharedInstance()?.transferOwnership(channel,
                                                         targetUserId: userId,
                                                         success: { channel in
                continuation.resume(returning: (true, nil, channel))
            }, failure: { (errorCode, error) in
                let klatError = KlatError.convert(errorCode: Int(errorCode) as Int, error: error)
                continuation.resume(returning: (false, klatError, nil))
            })
        }
    }
    /// leave channel
    func leaveChannel(channel:TPChannel) async -> (Bool, Error?)
    {
        guard isAuthenticated() == true else { return (false, KlatError.loginRequired) }
        return await withCheckedContinuation { continuation in
            TalkPlus.sharedInstance()?.leave(channel,
                                             deleteChannelIfEmpty: true,
                                             success: {
                continuation.resume(returning: (true, nil))
            }, failure: { (errorCode, error) in
                let klatError = KlatError.convert(errorCode: Int(errorCode) as Int, error: error)
                continuation.resume(returning: (false, klatError))
            })
        }
    }
    /// delete channel
    func deleteChannel(channel:TPChannel) async -> (Bool, Error?)
    {
        guard isAuthenticated() == true else { return (false, KlatError.loginRequired) }
        return await withCheckedContinuation { continuation in
            TalkPlus.sharedInstance()?.deleteChannel(channel.getId(), success: {
                continuation.resume(returning: (true, nil))
            }, failure: { (errorCode, error) in
                let klatError = KlatError.convert(errorCode: Int(errorCode) as Int, error: error)
                continuation.resume(returning: (false, klatError))
            })
        }
    }
    /// freeze channel
    func freezeChannel(channel:TPChannel) async -> (Bool, Error?)
    {
        guard isAuthenticated() == true else { return (false, KlatError.loginRequired) }
        return await withCheckedContinuation { continuation in
            TalkPlus.sharedInstance()?.freezeChannel(channel.getId(), success: {
                continuation.resume(returning: (true, nil))
            }, failure: { (errorCode, error) in
                let klatError = KlatError.convert(errorCode: Int(errorCode) as Int, error: error)
                continuation.resume(returning: (false, klatError))
            })
        }
    }
    /// unfreeze channel
    func unfreezeChannel(channel:TPChannel) async -> (Bool, Error?)
    {
        guard isAuthenticated() == true else { return (false, KlatError.loginRequired) }
        return await withCheckedContinuation { continuation in
            TalkPlus.sharedInstance()?.unfreezeChannel(channel.getId(), success: {
                continuation.resume(returning: (true, nil))
            }, failure: { (errorCode, error) in
                let klatError = KlatError.convert(errorCode: Int(errorCode) as Int, error: error)
                continuation.resume(returning: (false, klatError))
            })
        }
    }
    /// enable Channe lPushNotification
    func enableChannelPushNotification(channel:TPChannel, userId:String) async -> (Bool, Error?, TPChannel?)
    {
        guard isAuthenticated() == true else { return (false, KlatError.loginRequired, nil) }
        return await withCheckedContinuation { continuation in
            TalkPlus.sharedInstance()?.enableChannelPushNotification(channel, success: { chatChannel in
                continuation.resume(returning: (true, nil, chatChannel))
            }, failure: { (errorCode, error) in
                let klatError = KlatError.convert(errorCode: Int(errorCode) as Int, error: error)
                continuation.resume(returning: (false, klatError, nil))
            })
        }
    }
    
    /// disable Channe lPushNotification
    func disableChannelPushNotification(channel:TPChannel, userId:String) async -> (Bool, Error?, TPChannel?)
    {
        guard isAuthenticated() == true else { return (false, KlatError.loginRequired, nil) }
        return await withCheckedContinuation { continuation in
            TalkPlus.sharedInstance()?.disableChannelPushNotification(channel, success: { chatChannel in
                continuation.resume(returning: (true, nil, chatChannel))
            }, failure: { (errorCode, error) in
                let klatError = KlatError.convert(errorCode: Int(errorCode) as Int, error: error)
                continuation.resume(returning: (false, klatError, nil))
            })
        }
    }
}

extension Notification.Name {
    static let klat_messageReceived = Notification.Name("klat_messageReceived")
    static let klat_messageDeleted = Notification.Name("klat_messageDeleted")
    
    static let klat_memberAdded = Notification.Name("klat_memberAdded")
    static let klat_memberLeft = Notification.Name("klat_memberLeft")
    static let klat_memberBanned = Notification.Name("klat_memberBanned")
    static let klat_memberUnbanned = Notification.Name("klat_memberUnbanned")
    
    static let klat_channelAdded = Notification.Name("klat_channelAdded")
    static let klat_channelChanged = Notification.Name("klat_channelChanged")
    static let klat_channelRemoved = Notification.Name("klat_channelRemoved")
    
    static let klat_publicMemberAdded = Notification.Name("klat_publicMemberAdded")
    static let klat_publicMemberLeft = Notification.Name("klat_publicMemberLeft")
    static let klat_publicMemberBanned = Notification.Name("klat_publicMemberBanned")
    static let klat_publicMemberUnbanned = Notification.Name("klat_publicMemberUnbanned")
    
    static let klat_publicChannelAdded = Notification.Name("klat_publicChannelAdded")
    static let klat_publicChannelChanged = Notification.Name("klat_publicChannelChanged")
    static let klat_publicChannelRemoved = Notification.Name("klat_publicChannelRemoved")
    
    static let klat_moveToOneToOneChannel = Notification.Name("klat_moveToOnetoOneChannel")
    static let klat_reactionUpdated = Notification.Name("klat_reactionUpdated")
}

extension KlatChatAPIs: TPChannelDelegate {
    /// Message
    func messageReceived(_ tpChannel: TPChannel!, message tpMessage: TPMessage!) {
        NotificationCenter.default.post(
            name: .klat_messageReceived,
            object: nil,
            userInfo: ["channel": tpChannel!, "message": tpMessage!]
        )
    }
    func messageDeleted(_ tpChannel: TPChannel!, message tpMessage: TPMessage!) {
        NotificationCenter.default.post(
            name: .klat_messageDeleted,
            object: nil,
            userInfo: ["channel": tpChannel!, "message": tpMessage!]
        )
    }
    /// reaction
    func reactionUpdated(_ tpChannel: TPChannel!, message tpMessage: TPMessage!) {
        NotificationCenter.default.post(
            name: .klat_reactionUpdated,
            object: nil,
            userInfo: ["channel": tpChannel!, "message": tpMessage!]
        )
    }
    /// Channels
    func memberAdded(_ tpChannel: TPChannel!, users: [TPMember]!) {
        NotificationCenter.default.post(
            name: .klat_memberAdded,
            object: nil,
            userInfo: ["channel": tpChannel!, "members": users!]
        )
    }
    func memberLeft(_ tpChannel: TPChannel!, users: [TPMember]!) {
        NotificationCenter.default.post(
            name: .klat_memberLeft,
            object: nil,
            userInfo: ["channel": tpChannel!, "members": users!]
        )
    }
    func channelAdded(_ tpChannel: TPChannel!) {
        NotificationCenter.default.post(
            name: .klat_channelAdded,
            object: nil,
            userInfo: ["channel": tpChannel!]
        )
    }
    func channelChanged(_ tpChannel: TPChannel!) {
        NotificationCenter.default.post(
            name: .klat_channelChanged,
            object: nil,
            userInfo: ["channel": tpChannel!]
        )
    }
    func channelRemoved(_ tpChannel: TPChannel!) {
        NotificationCenter.default.post(
            name: .klat_channelRemoved,
            object: nil,
            userInfo: ["channel": tpChannel!]
        )
    }
    func memberBanned(_ tpChannel: TPChannel!, users: [TPMember]!) {
        NotificationCenter.default.post(
            name: .klat_memberBanned,
            object: nil,
            userInfo: ["channel": tpChannel!, "users":users!]
        )
    }
    func memberUnbanned(_ tpChannel: TPChannel!, users: [TPMember]!) {
        NotificationCenter.default.post(
            name: .klat_memberUnbanned,
            object: nil,
            userInfo: ["channel": tpChannel!, "users":users!]
        )
    }
    /// Public Channels
    func publicMemberAdded(_ tpChannel: TPChannel!, users: [TPMember]!) { 
        NotificationCenter.default.post(
            name: .klat_publicMemberAdded,
            object: nil,
            userInfo: ["channel": tpChannel!, "members": users!]
        )
    }
    func publicMemberLeft(_ tpChannel: TPChannel!, users: [TPMember]!) { 
        NotificationCenter.default.post(
            name: .klat_publicMemberLeft,
            object: nil,
            userInfo: ["channel": tpChannel!, "members": users!]
        )
    }
    func publicChannelAdded(_ tpChannel: TPChannel!) { 
        NotificationCenter.default.post(
            name: .klat_publicChannelAdded,
            object: nil,
            userInfo: ["channel": tpChannel!]
        )
    }
    func publicChannelChanged(_ tpChannel: TPChannel!) { 
        NotificationCenter.default.post(
            name: .klat_publicChannelChanged,
            object: nil,
            userInfo: ["channel": tpChannel!]
        )
    }
    func publicChannelRemoved(_ tpChannel: TPChannel!) { 
        NotificationCenter.default.post(
            name: .klat_publicChannelRemoved,
            object: nil,
            userInfo: ["channel": tpChannel!]
        )
    }
    func publicMemberBanned(_ tpChannel: TPChannel!, users: [TPMember]!) {
        NotificationCenter.default.post(
            name: .klat_publicMemberBanned,
            object: nil,
            userInfo: ["channel": tpChannel!, "users":users!]
        )
    }
    func publicMemberUnbanned(_ tpChannel: TPChannel!, users: [TPMember]!) {
        NotificationCenter.default.post(
            name: .klat_publicMemberUnbanned,
            object: nil,
            userInfo: ["channel": tpChannel!, "users":users!]
        )
    }
}
