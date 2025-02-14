
import Foundation
import TalkPlus

open class KlatMemberInfoViewModel : KlatBaseViewModel {
    
    var didMutedMemberUpdated:(() -> Void)?
    var didChatChannelChanged:((TPChannel?) -> Void)?
    var mutedMembers:[TPMember] = []
    
    private var targetChannel:TPChannel?
    
    init(targetChannel: TPChannel) {
        super.init()
        self.targetChannel = targetChannel
    }
    
    override func klatReactionUpdated(channel:TPChannel, message:TPMessage) {}
    override func newKlatChannelAdded(channels: [TPChannel]) {}
    override func klatMoveToPrivateChannel(channel:TPChannel) {}
    override func klatChannelRemoved(channel: TPChannel) {}
    override func klatMessageReceived(channel: TPChannel, messages: [TPMessage]) {}
    override func klatMessageDeleted(channel: TPChannel, messages: [TPMessage]) {}
    override func klatMemberLeft(channel: TPChannel, members: [TPMember]) {}
    override func klatMemberAdded(channel: TPChannel, members: [TPMember]) {}
    override func klatMemberBanned(channel:TPChannel, members:[TPMember]) { 
        guard self.targetChannel?.getId() == channel.getId() else { return }
        self.targetChannel = channel
        DispatchQueue.main.async { [weak self] in
            self?.didChatChannelChanged?(channel)
        }
    }
    override func klatMemberUnbanned(channel:TPChannel, members:[TPMember]) { }
    override func klatChannelChanged(channel: TPChannel) {
        guard self.targetChannel?.getId() == channel.getId() else { return }
        self.targetChannel = channel
        DispatchQueue.main.async { [weak self] in
            self?.didChatChannelChanged?(channel)
        }
    }
}

extension KlatMemberInfoViewModel {
    
    func isMutedMember(memberId:String) -> Bool {
        guard mutedMembers.count > 0 else { return false }
        let members = mutedMembers.compactMap { $0.getId()}
        return members.contains(memberId)
    }
    
    func requestMutedMembers() {
        if isChannelOwner(channel: targetChannel) {
            requestMutedMembers(lastMember: nil, memberList: nil)
            return
        }
        requestMutedPeers(lastMember: nil, memberList: nil)
    }
        
    private func requestMutedPeers(lastMember:TPMember? = nil, memberList:[TPMember]?) {
        Task {
            var memberArray:[TPMember] = memberList ?? []
            guard let channel = self.targetChannel else { return }
            let result = await KlatChatAPIs.shared.getMutedPeers(channel: channel, lastMember: lastMember)
            if let members = result.2 { memberArray.append(contentsOf: members) }
            if result.0 == true, result.3 == true { // hasNext
                requestMutedPeers(lastMember: result.2?.last, memberList: memberArray)
                return
            }
            mutedMembers.removeAll()
            mutedMembers.append(contentsOf: memberArray)
            await MainActor.run {
                didMutedMemberUpdated?()
            }
        }
    }
    
    private func requestMutedMembers(lastMember:TPMember? = nil, memberList:[TPMember]?) {
        Task {
            var memberArray:[TPMember] = memberList ?? []
            guard let channel = self.targetChannel else { return }
            let result = await KlatChatAPIs.shared.getMutedMembers(channel: channel, lastMember: lastMember)
            if let members = result.2 { memberArray.append(contentsOf: members) }
            if result.0 == true, result.3 == true { // hasNext
                requestMutedMembers(lastMember: result.2?.last, memberList: memberArray)
                return
            }
            mutedMembers.removeAll()
            mutedMembers.append(contentsOf: memberArray)
            await MainActor.run {
                didMutedMemberUpdated?()
            }
        }
    }
    
    func requestOneToOneChat(targetUser:TPUser?) async throws {
        
        guard let targetUser = targetUser else { throw KlatError.invalidUser }
        
        do {
            /// first, try to join the invitation channel.
            if let channel = try await joinInvitationChatChannel(targetUser: targetUser) {
                if channel.getMembers().count < 2 {
                    /// in case of that target user is not joined in the chat channel.
                    try await addMember(targetUser: targetUser, channel: channel)
                }
                postMoveOneToOneChannelNotification(channel)
                return
            }
        } catch let error as KlatError {
            /// throws an error except for 'channelNotFound'
            if error != .channelNotFound { throw error }
        }
        
        do {
            /// in case of that Chat channel does not exist, create an invitation chat channel.
            if let channel = try await createInvitationChannel(targetUser: targetUser) {
                postMoveOneToOneChannelNotification(channel)
            }
        } catch let error {
            throw error
        }
    }
    
    private func postMoveOneToOneChannelNotification(_ channel:TPChannel) {
        NotificationCenter.default.post(
            name: .klat_moveToOneToOneChannel,
            object: nil,
            userInfo: ["channel": channel]
        )
    }
    
    private func joinInvitationChatChannel(targetUser:TPUser) async throws -> TPChannel? {
        guard let loginUserId = KlatChatAPIs.shared.loginUser?.getId() else { throw KlatError.invalidUser }
        guard let targetUserId = targetUser.getId() else { throw KlatError.invalidUser }
        guard targetUserId != loginUserId else { throw KlatError.invalidUser }
        // Ascending Order
        let members = [ loginUserId, targetUserId ].sorted { $0.lowercased() < $1.lowercased() }
        let channelId = "klat_uikit_invitation_\(members[0])_\(members[1])"
        let invitationCode = "\(members[0])_\(members[1])"
        let result = await KlatChatAPIs.shared.joinChannel(channelId: channelId, invitationCode: invitationCode)
        if let error = result.1 { throw error }
        return result.2
    }
    
    private func createInvitationChannel(targetUser:TPUser) async throws -> TPChannel? {
        guard let loginUserId = KlatChatAPIs.shared.loginUser?.getId() else { throw KlatError.invalidUser }
        var loginUserName = KlatChatAPIs.shared.loginUser?.getUsername() ?? ""
        loginUserName.isEmpty ? loginUserName = KlatChatAPIs.shared.loginUser?.getId() ??  "" : ()
        
        guard let targetUserId = targetUser.getId() else { throw KlatError.invalidUser }
        var targetUserName = targetUser.getUsername() ?? ""
        targetUserName.isEmpty ? targetUserName = targetUser.getId() ??  "" : ()
        
        // Ascending Order
        let members = [ loginUserId, targetUserId ].sorted { $0.lowercased() < $1.lowercased() }
        // TPChannelQueryParams
        let params = TPChannelCreateParams(channelType: .invitationOnly)!
        params.channelName = "\(targetUserName),\(loginUserName)"
        params.targetIds = members
        params.channelId = "klat_uikit_invitation_\(members[0])_\(members[1])"
        params.invitationCode = "\(members[0])_\(members[1])"
        params.hideMessagesBeforeJoin = false
        let result = await KlatChatAPIs.shared.createNewChannel(params: params)
        if let error = result.1 { throw error }
        return result.2
    }
    
    private func addMember(targetUser:TPUser, channel:TPChannel) async throws {
        let result = await KlatChatAPIs.shared.addMember(user: targetUser, channel: channel)
        if let error = result.1 { throw error }
    }
    
    func banMember(userId:String) async throws {
        guard let channel = self.targetChannel else { throw KlatError.invalidChannel }
        guard userId.count > 0 else { throw KlatError.invalidUser }
        let result = await KlatChatAPIs.shared.banMember(channel: channel, userId: userId)
        if let error = result.1 { throw error }
    }
    
    func mute(userId:String) async throws {
        guard let channel = self.targetChannel else { throw KlatError.invalidChannel }
        let isOwner = isChannelOwner(channel: channel)
        do {
            if isOwner {
                try await muteMember(userId: userId)
            } else {
                try await mutePeer(userIds: [userId])
            }
        } catch {
            throw error
        }
    }
    
    func unmute(userId:String) async throws {
        guard let channel = self.targetChannel else { throw KlatError.invalidChannel }
        let isOwner = isChannelOwner(channel: channel)
        do {
            if isOwner {
                try await unmuteMember(userId: userId)
            } else {
                try await unmutePeer(userIds: [userId])
            }
        } catch {
            throw error
        }
    }
    
    private func mutePeer(userIds:[String]) async throws {
        guard let channel = self.targetChannel else { throw KlatError.invalidChannel }
        guard userIds.count > 0 else { throw KlatError.invalidUser }
        let result = await KlatChatAPIs.shared.mutePeers(channel: channel, userIds: userIds)
        if let error = result.1 { throw error }
        requestMutedPeers(lastMember: nil, memberList: nil)
    }
    
    private func unmutePeer(userIds:[String]) async throws {
        guard let channel = self.targetChannel else { throw KlatError.invalidChannel }
        guard userIds.count > 0 else { throw KlatError.invalidUser }
        let result = await KlatChatAPIs.shared.unmutePeers(channel: channel, userIds: userIds)
        if let error = result.1 { throw error }
        requestMutedPeers(lastMember: nil, memberList: nil)
    }
    
    private func muteMember(userId:String) async throws {
        guard let channel = self.targetChannel else { throw KlatError.invalidChannel }
        guard userId.count > 0 else { throw KlatError.invalidUser }
        let result = await KlatChatAPIs.shared.muteMember(channel: channel, memberId: userId)
        if let error = result.1 { throw error }
        requestMutedMembers(lastMember: nil, memberList: nil)
    }
    
    private func unmuteMember(userId:String) async throws {
        guard let channel = self.targetChannel else { throw KlatError.invalidChannel }
        guard userId.count > 0 else { throw KlatError.invalidUser }
        let result = await KlatChatAPIs.shared.unmuteMember(channel: channel, memberId: userId)
        if let error = result.1 { throw error }
        requestMutedMembers(lastMember: nil, memberList: nil)
    }
    
    func transferChannelOwner(userId:String) async throws {
        guard let channel = self.targetChannel else { throw KlatError.invalidChannel }
        guard userId.count > 0 else { throw KlatError.invalidUser }
        let result = await KlatChatAPIs.shared.transferChannelOwner(channel: channel, userId: userId)
        if let error = result.1 { throw error }
    }
    
    func updateUserProfileImage(member:TPUser?, image:UIImage?) async throws {
        guard let image = image else { throw KlatError.invalidImage }
        guard let member = member else { throw KlatError.invalidUser }
        let result = await KlatChatAPIs.shared.updateUserProfile(userName: member.getUsername(),
                                                        profileImage: image,
                                                        metaData: member.getData())
        if let error = result.1 { throw error }
    }
}
