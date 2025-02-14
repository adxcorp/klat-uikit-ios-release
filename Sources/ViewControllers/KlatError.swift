
import Foundation

public enum KlatError: Error, LocalizedError {
    case invalidChannel
    case invalidMessage
    case invalidUser
    case invalidImage
    case unknownError
    // Klat API Errors
    case paramsBindingError
    case invalidParams
    case internalServerError
    case unauthorized
    case loginRequired
    case tooManyRequests
    case invalidMetaData
    case deactivatedApp
    case invalidPrivateData
    case invalidPrivateTag
    case invalidMemberInfo
    case channelOwnerNotFound
    case channelMemberNotFound
    case channelIdAlreadyTaken
    case channelNotFound
    case reuseChannelMembersDoNotMatch
    case userNotChannelMember
    case channelUpdateNotAuthorized
    case cannotRemoveChannelOwner
    case alreadyMember
    case removeUserNotMember
    case banUserNotMember
    case cannotJoinPrivateChannel
    case invitationCodeRequired
    case invitationCodeCannotBeEmpty
    case wrongInvitationCode
    case channelNotInvitationOnlyType
    case cannotBanOwnerFromChannel
    case cannotAddBannedUser
    case bannedFromChannel
    case cannotCreateChannelWithBlockedMember
    case cannotCreateChannelWhenBlockedByMember
    case cannotAddBlockedMember
    case cannotAddMemberWhenBlockedByMember
    case cannotJoinChannelBlockedByOwner
    case cannotJoinChannelBlockedOwner
    case cannotSendMessageInFrozenChannel
    case mentionedUserDoesNotExist
    case mutedInChannel
    case cannotMuteChannelOwner
    case maxChannelMemberCountExceeded
    case alreadyChannelOwner
    case notChannelOwner
    case sessionNotFound
    case sessionTokenInvalid
    case userNotFound
    case userIDTaken
    case appNotFound
    case anonymousLoginNotAllowed
    case wrongPassword
    case invalidLoginToken
    case deactivatedUser
    case senderNotChannelMember
    case msgSizeLimitExceeded
    case bothMsgTextDataMissing
    case cannotBlockSelf
    case cannotUnblockSelf
    case userNotBlocked
    case fileUploadFail
    case fileSizeLimitExceeded
    
    public static func convert(errorCode:Int, error:Error?) -> Error? {
        switch(errorCode) {
        case 1001: return KlatError.paramsBindingError
        case 1002: return KlatError.invalidParams
        case 1003: return KlatError.internalServerError
        case 1004: return KlatError.internalServerError
        case 1005: return KlatError.internalServerError
        case 1006: return KlatError.unauthorized
        case 1007: return KlatError.loginRequired
        case 1010: return KlatError.tooManyRequests
        case 1011: return KlatError.invalidMetaData
        case 1012: return KlatError.deactivatedApp
        case 1013: return KlatError.invalidPrivateData
        case 1014: return KlatError.invalidPrivateTag
        case 1015: return KlatError.invalidMemberInfo
        case 2000: return KlatError.channelOwnerNotFound
        case 2001: return KlatError.channelMemberNotFound
        case 2002: return KlatError.channelIdAlreadyTaken
        case 2003: return KlatError.channelNotFound
        case 2004: return KlatError.reuseChannelMembersDoNotMatch
        case 2005: return KlatError.userNotChannelMember
        case 2006: return KlatError.channelUpdateNotAuthorized
        case 2007: return KlatError.cannotRemoveChannelOwner
        case 2008: return KlatError.alreadyMember
        case 2009: return KlatError.removeUserNotMember
        case 2010: return KlatError.banUserNotMember
        case 2011: return KlatError.cannotJoinPrivateChannel
        case 2012: return KlatError.invitationCodeRequired
        case 2013: return KlatError.invitationCodeCannotBeEmpty
        case 2014: return KlatError.wrongInvitationCode
        case 2015: return KlatError.channelNotInvitationOnlyType
        case 2016: return KlatError.cannotBanOwnerFromChannel
        case 2017: return KlatError.cannotAddBannedUser
        case 2018: return KlatError.bannedFromChannel
        case 2019: return KlatError.cannotCreateChannelWithBlockedMember
        case 2020: return KlatError.cannotCreateChannelWhenBlockedByMember
        case 2021: return KlatError.cannotAddBlockedMember
        case 2022: return KlatError.cannotAddMemberWhenBlockedByMember
        case 2023: return KlatError.cannotJoinChannelBlockedByOwner
        case 2024: return KlatError.cannotJoinChannelBlockedOwner
        case 2025: return KlatError.cannotSendMessageInFrozenChannel
        case 2026: return KlatError.mentionedUserDoesNotExist
        case 2027: return KlatError.mutedInChannel
        case 2028: return KlatError.cannotMuteChannelOwner
        case 2029: return KlatError.maxChannelMemberCountExceeded
        case 2030: return KlatError.alreadyChannelOwner
        case 2031: return KlatError.notChannelOwner
        case 3000: return KlatError.internalServerError
        case 3001: return KlatError.sessionNotFound
        case 3002: return KlatError.sessionTokenInvalid
        case 3003: return KlatError.userNotFound
        case 3004: return KlatError.userIDTaken
        case 3005: return KlatError.appNotFound
        case 3006: return KlatError.anonymousLoginNotAllowed
        case 3007: return KlatError.internalServerError
        case 3008: return KlatError.wrongPassword
        case 3009: return KlatError.invalidLoginToken
        case 3010: return KlatError.deactivatedUser
        case 4000: return KlatError.senderNotChannelMember
        case 4001: return KlatError.msgSizeLimitExceeded
        case 4002: return KlatError.bothMsgTextDataMissing
        case 5000: return KlatError.cannotBlockSelf
        case 5001: return KlatError.cannotUnblockSelf
        case 5002: return KlatError.userNotBlocked
        case 6000: return KlatError.fileUploadFail
        case 6001: return KlatError.fileSizeLimitExceeded
        default:
            return error
        }
    }
    
    public var errorDescription: String? {
        switch self {
        case .invalidChannel:                           return NSLocalizedString("실패: 유효하지 않은 채널", comment: "")
        case .invalidMessage:                           return NSLocalizedString("실패: 유효하지 않은 메시지", comment: "")
        case .invalidUser:                              return NSLocalizedString("실패: 유효하지 않은 유저", comment: "")
        case .invalidImage:                             return NSLocalizedString("실패: 유효하지 않은 이미지", comment: "")
        case .unknownError:                             return NSLocalizedString("실패: 알 수 없는 에러", comment: "")
        case .paramsBindingError:                       return NSLocalizedString("실패: 잘못된 파라미터", comment: "")
        case .invalidParams:                            return NSLocalizedString("실패: 필수 파라미터 누락", comment: "")
        case .internalServerError:                      return NSLocalizedString("실패: 서버 에러 발생 (재시도 또는 문의)", comment: "")
        case .unauthorized:                             return NSLocalizedString("실패: 잘못된 권한", comment: "")
        case .loginRequired:                            return NSLocalizedString("실패: 로그인 필요", comment: "")
        case .tooManyRequests:                          return NSLocalizedString("실패: API RateLimit 제한", comment: "")
        case .invalidMetaData:                          return NSLocalizedString("실패: 잘못된 형식의 Meta Data", comment: "")
        case .deactivatedApp:                           return NSLocalizedString("실패: 앱이 비활성화 상태", comment: "")
        case .invalidPrivateData:                       return NSLocalizedString("실패: 잘못된 채널 Private Data 형식", comment: "")
        case .invalidPrivateTag:                        return NSLocalizedString("실패: 잘못된 채널 Private Tag 형식", comment: "")
        case .invalidMemberInfo:                        return NSLocalizedString("실패: 잘못된 채널 Member Info 형식", comment: "")
        case .channelOwnerNotFound:                     return NSLocalizedString("실패: 존재하지 않는 채널 주인(Owner)", comment: "")
        case .channelMemberNotFound:                    return NSLocalizedString("실패: 채널에 요청한 사용자가 미존재", comment: "")
        case .channelIdAlreadyTaken:                    return NSLocalizedString("실패: 이미 사용되고 있는 채널 ID", comment: "")
        case .channelNotFound:                          return NSLocalizedString("실패: 존재하지 않는 채널", comment: "")
        case .reuseChannelMembersDoNotMatch:            return NSLocalizedString("실패: 요청한 채널 멤버 정보와 Reuse하려는 채널의 멤버 정보와 미일치", comment: "")
        case .userNotChannelMember:                     return NSLocalizedString("실패: 사용자가 채널의 멤버가 아닙니다.", comment: "")
        case .channelUpdateNotAuthorized:               return NSLocalizedString("실패: 채널을 수정할 권한이 없음", comment: "")
        case .cannotRemoveChannelOwner:                 return NSLocalizedString("실패: 채널 주인을 채널에서 제거할 수 없음", comment: "")
        case .alreadyMember:                            return NSLocalizedString("실패: 이미 채널 멤버로 등록되어 있음", comment: "")
        case .removeUserNotMember:                      return NSLocalizedString("실패: 채널 멤버가 아닌 사용자를 채널에서 제거할 수 없음", comment: "")
        case .banUserNotMember:                         return NSLocalizedString("실패: 차단하려는 사용자가 채널에 멤버로 등록되어 있지 않음", comment: "")
        case .cannotJoinPrivateChannel:                 return NSLocalizedString("실패: Private Channel에 초대없이 가입할 수 없음", comment: "")
        case .invitationCodeRequired:                   return NSLocalizedString("실패: 초대코드 없이 채널에 가입할 수 없음", comment: "")
        case .invitationCodeCannotBeEmpty:              return NSLocalizedString("실패: 초대코드 누락", comment: "")
        case .wrongInvitationCode:                      return NSLocalizedString("실패: 잘못된 초대코드", comment: "")
        case .channelNotInvitationOnlyType:             return NSLocalizedString("실패: InvitationOnly 채널 타입이 아닙니다.", comment: "")
        case .cannotBanOwnerFromChannel:                return NSLocalizedString("실패: 채널 소유자를 차단할 수 없음", comment: "")
        case .cannotAddBannedUser:                      return NSLocalizedString("실패: 차단된 사용자를 초대할 수 없음", comment: "")
        case .bannedFromChannel:                        return NSLocalizedString("실패: 채널에서 차단되었습니다", comment: "")
        case .cannotCreateChannelWithBlockedMember:     return NSLocalizedString("실패: 내가 차단한 사용자를 채널 멤버에 포함할 수 없음", comment: "")
        case .cannotCreateChannelWhenBlockedByMember:   return NSLocalizedString("실패: 나를 차단한 사용자를 채널 멤버에 포함할 수 없음", comment: "")
        case .cannotAddBlockedMember:                   return NSLocalizedString("실패: 내가 차단한 사용자를 초대할 수 없음", comment: "")
        case .cannotAddMemberWhenBlockedByMember:       return NSLocalizedString("실패: 나를 차단한 사용자를 초대할 수 없음", comment: "")
        case .cannotJoinChannelBlockedByOwner:          return NSLocalizedString("실패: 나를 차단한 사용자가 채널 주인인 채널에 가입할 수 없음", comment: "")
        case .cannotJoinChannelBlockedOwner:            return NSLocalizedString("실패: 내가 차단한 사용자가 채널 주인인 채널에 가입할 수 없음", comment: "")
        case .cannotSendMessageInFrozenChannel:         return NSLocalizedString("실패: 프리징된 채널에 메시지를 보낼 수 없음", comment: "")
        case .mentionedUserDoesNotExist:                return NSLocalizedString("실패: Mention하려는 사용자가 채널에 미존재", comment: "")
        case .mutedInChannel:                           return NSLocalizedString("실패: 채널에서 Mute된 상태", comment: "")
        case .cannotMuteChannelOwner:                   return NSLocalizedString("실패: 채널 소유자를 Mute 할 수 없음", comment: "")
        case .maxChannelMemberCountExceeded:            return NSLocalizedString("실패: 채널 최대 인원 초과", comment: "")
        case .alreadyChannelOwner:                      return NSLocalizedString("실패: 지목한 사용자가 이미 해당 채널의 주인", comment: "")
        case .notChannelOwner:                          return NSLocalizedString("실패: 채널 주인이 아니면 진행할 수 없는 요청", comment: "")
        case .sessionNotFound:                          return NSLocalizedString("실패: 존재하지 않은 세션 (토큰값 확인 필요)", comment: "")
        case .sessionTokenInvalid:                      return NSLocalizedString("실패: 잘못된 세션 정보 (토큰값 확인 필요)", comment: "")
        case .userNotFound:                             return NSLocalizedString("실패: 존재하지 않는 사용자", comment: "")
        case .userIDTaken:                              return NSLocalizedString("실패: 이미 사용되고 있는 사용자 ID", comment: "")
        case .appNotFound:                              return NSLocalizedString("실패: 존재하지 않은 APP", comment: "")
        case .anonymousLoginNotAllowed:                 return NSLocalizedString("실패: 익명 로그인 기능 비활성화", comment: "")
        case .wrongPassword:                            return NSLocalizedString("실패: 잘못된 암호", comment: "")
        case .invalidLoginToken:                        return NSLocalizedString("실패: 잘못된 로그인 토큰 (토큰값 확인 필요)", comment: "")
        case .deactivatedUser:                          return NSLocalizedString("실패: 비활성화 된 사용자", comment: "")
        case .senderNotChannelMember:                   return NSLocalizedString("실패: 채널 멤버만 메시지 전송이 가능", comment: "")
        case .msgSizeLimitExceeded:                     return NSLocalizedString("실패: 허용된 메시지 사이즈를 초과", comment: "")
        case .bothMsgTextDataMissing:                   return NSLocalizedString("실패: 메시지 텍스트 또는 데이터가 없음", comment: "")
        case .cannotBlockSelf:                          return NSLocalizedString("실패: 사용자 스스로를 차단할 수 없음", comment: "")
        case .cannotUnblockSelf:                        return NSLocalizedString("실패: 사용자 스스로를 차단 해제할 수 없음", comment: "")
        case .userNotBlocked:                           return NSLocalizedString("실패: 차단한 사용자가 아님", comment: "")
        case .fileUploadFail:                           return NSLocalizedString("실패: 파일 업로드 실패", comment: "")
        case .fileSizeLimitExceeded:                    return NSLocalizedString("실패: 최대 파일 업로드 사이즈 초과", comment: "")
        }
    }
}
