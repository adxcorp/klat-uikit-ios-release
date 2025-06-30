
# Klat-UIKit-iOS

![Platform](https://img.shields.io/badge/platform-iOS-orange.svg)
![Languages](https://img.shields.io/badge/language-Swift-orange.svg)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)

## Klat UIKit SDK  소개

Klat UIKit SDK는 Swift 언어로 작성되었으며, 채팅 기능을 iOS 클라이언트 앱에 쉽고 빠르게 통합할 수 있는 유저 인터페이스 키트 (User Inerface Kit) 입니다. 이 저장소에서는 Klat UIKit SDK를 iOS 앱 프로젝트에 구현하기 전에 알아야 할 필수 정보와 샘플 앱을 테스트을 위한 절차에 대해서 설명하고 있습니다.

<br />

## Klat UIKit SDK 최소 요구사항

- Xcode 16.0+
>2025년 4월 24일부터 앱 스토어 커넥트에 업로드하는 앱은 Xcode 16 이상 버전을 사용하여 빌드해야 합니다. 
- iOS 13.0+
>iOS 15.0+ 권장
- Swift 5.5+
- [Klat Chat SDK for iOS](https://github.com/adxcorp/talkplus-ios-release) 1.0.1+

<br />

## Klat UIKit SDK 설치
iOS용 Klat UIKit SDK는 CocoaPods 또는 Swift Package Manager를 통해 설치할 수 있습니다.

 ### - 코코아팟 (CocoaPods)
 ```ruby
pod 'klat-uikit-ios'
```

macOS에서 터미널 (Terminal) 실행하고,  iOS 앱 프로젝트 디렉토리로 이동 한 다음에 아래 명령어를 활용하여 `Podfile`을 열어 주십시오.

```bash
$ open Podfile
```

아래와 같이 `Podfile` 파일에 `pod 'klat-uikit-ios'` 를 추가하여 주십시오.

```bash
platform :ios, '13.0'
 
target 'Project' do
    use_frameworks!
    pod 'klat-uikit-ios'
end
```

**CocoaPods CLI** 명령어를 이용하여 SDK 설치를 완료하여 주십시오.

```bash
$ pod install --repo-update
```

 ### - 스위프트 패키지 매니저 (Swift Package Manager)
1. Xcode에서 아래 메뉴를 순서대로 클릭합니다.
> Xcode -> File -> Add Package Dependencies...
2. 우측 상단 패키지 URL에 아래 저장소 URL를 입력합니다.
```bash
https://github.com/adxcorp/klat-uikit-ios-release.git
```
3. 사용하려는 버전을 선택하고 "Add Package" 버튼을 클릭하여 SDK 설치를 완료합니다.

<br />

 ## 필요 권한
Klat UIKit SDK는 카메라로 촬영된 사진 또는 앨범에 있는 사진을 전송할 수 있는 기능을 포함하고 있으며, 또한 앨범에 사진을 저장할 수 있는 기능을 제공하고 있습니다. 이 기능을 사용하려면 아래의 권한을 유저에게 요청하여 획득해야 합니다.

 - Xcode 프로젝트 > 빌드타겟 선택 > Info > Custom iOS Target Properties >
    <br />`Privacy - Photo Library Additions Usage Description`
    <br />`Privacy - Photo Library Usage Description`
    <br />`Privacy - Camera Usage Description`

```xml
<key>NSPhotoLibraryUsageDescription</key>
    <string>$(PRODUCT_NAME) would like access to your photo library</string>
<key>NSCameraUsageDescription</key>
    <string>$(PRODUCT_NAME) would like to use your camera</string>
<key>NSPhotoLibraryAddUsageDescription</key>
    <string>$(PRODUCT_NAME) would like to save photos to your photo library</string>
```

<br />

## 샘플 앱 주요 기능

### - 샘플 앱 주요 기능
- 텍스트 메시지 전송
- 앨범 사진 / 카메라 촬영 사진 전송
- 메시지 제어 및 부가 기능
    <br />: 텍스트 메시지 복사 
    <br />: 메시지 삭제 
    <br />: 10가지 이모지 지원
- 채팅 채널 목록 표시 
- 채팅 채널 생성
- 검색어를 이용한 채팅 채널 필터링
- 채팅 채널 정보 변경 및 제어
    <br />: 메시지 전송 못하게 막기 
    <br />: FCM 푸시 메시지 활성화/비활성화
    <br />: 채널 나가기, 채널 삭제
- 사용자 제어 
    <br />: 음소거  (Mute / Unmute)
    <br />: 강제 퇴장 (Ban)
    <br />: 운영자 (Channel Owner) 권한 부여
    
> 다크 모드 (Dark Mode) 미지원. 

> 채팅 채널을 나타내는 객체 정보에 채팅에 참여한 멤버 정보가 없는 특수 채널 (예: 슈퍼 채널)에 대해서는 샘플 코드가 정상적으로 동작하지 않음. 

<br />

## 샘플 앱으로 시작하기
샘플 앱을 테스트하려면 아래에 기술된 절차를 따라주십시오.
>Klat UIKit SDK를 자신의 iOS 앱에 적용하기 전에 GitHub 저장소에서 샘플 앱을 다운로드하여, 어떤 기능을 적용할 수 있을지 미리 확인하시는 것을 권장합니다.

>샘플 앱 프로젝트에는 Swift 언어로 작성된 Klat UIKit 소스코드를 포함하고 있으므로 추가적으로 Klat UIKit SDK를 설치할 필요가 없습니다.

### 1. [Klat 대시보드](https://www.klat.kr/) > App ID 확인 및 익명 로그인 활성화
```
1-1. Klat 대시보드 로그인 또는 회원 가입
1-2. Klat 대시보드 > Apps > `새로운 앱 만들기` 버튼을 클릭하여 Klat 애플리케이션 생성
1-3. Klat 대시보드 > Apps > [생성된 앱 이름] > Settings > `App ID` 확인
1-4. Klat 대시보드 > Apps > [생성된 앱 이름] > Settings > `익명 로그인 (Anonymous user)` 활성화
```
### 2. 애플리케이션 식별자 (App ID), 채널 식별자 (Channel ID), 유저 식별자 (User ID) 입력
```
2-1. Klat UIKit 샘플 앱 (KlatUIKit.xcodeproj) 프로젝트 파일 열기
2-2. `AppDelegate.swift` 파일 
      > `application(_:didFinishLaunchingWithOptions:)` 메소드 
      > `YOUR_APP_ID` 문자열을 위의 이전 단계에서 생성한 `App ID`로 교체
2-3. iOS 샘플 앱 실행 후, 로그인 화면에서 유저 식별자 (`User ID`) 및 닉네임 (`Nick Name`) 입력한 다음에 로그인 버튼 (Sign In) 클릭
```

### 3. [Klat 대시보드](https://www.klat.kr/) > 채널 생성 및 멤버 추가
```
3-1. Klat 대시보드 > Apps > [생성된 앱 이름] > Channel > `채널 생성` 클릭
3-2. 채널 타입은 `PRIVATE` 선택, `채널명` 입력, `멤버 설정`에서 익명으로 로그인 된 유저를 검색하여 추가한 다음에 `생성` 버튼 클릭
     * 이 단계에서 샘플 앱의 채널 목록에 채널이 추가됩니다.
3-3. 샘플 앱 테스트
```
<br />

## 예제 코드 

### - Klat SDK 초기화 
 ```swift
// AppDelegate.swift
import TalkPlus
import KlatUIKit

func application(_ application: UIApplication, 
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool 
{
    // KLAT SDK (채팅 SDK) 초기화, 앱 실행 후 최초 1회 실행
    let KLAT_APP_ID = "<YOUR_APP_ID>"
    TalkPlus.sharedInstance().initWithAppId(KLAT_APP_ID)
    return true
}
```

### - 익명 로그인
 ```swift
import TalkPlus
import KlatUIKit
                
// 익명 로그인
func signIn() {
    let signInParams = TPLoginParams(loginType: TPLoginType.anonymous, userId: "<USER_ID>")
    signInParams?.userName = "<NICK_NAME>"
    
    TalkPlus.sharedInstance()?.login(signInParams, success: { [weak self] tpUser in
        guard let self = self else { return }
        ///showChannelListViewController()
        ///showChatMessageViewController(channelId: "<CHANNEL_ID>")
    }, failure: { [weak self] (errorCode, error) in

    })
}
```

### - 토큰 로그인
 ```swift
import TalkPlus
import KlatUIKit
                
// 토큰 로그인
func signIn() {
    let signInParams = TPLoginParams(loginType: TPLoginType.token, userId: "<USER_ID>")
    signInParams?.userName = "<NICK_NAME>"
    signInParams?.userName = "<USER_TOKEN>"
    
    TalkPlus.sharedInstance()?.login(signInParams, success: { [weak self] tpUser in
        guard let self = self else { return }
        ///showChannelListViewController()
        ///showChatMessageViewController(channelId: "<CHANNEL_ID>")
    }, failure: { [weak self] (errorCode, error) in

    })
}
```

### - 채팅 목록 화면으로 이동하기
```swift
import TalkPlus
import KlatUIKit
                
// 로그인 성공 후, 채팅 목록 화면으로 이동하기
func showChannelListViewController() {
    let bundle = Bundle(for: KlatChannelListViewController.self)
    let nibName = String(describing: KlatChannelListViewController.self)
    let klatUIKitVC = KlatChannelListViewController(nibName: nibName, bundle: bundle)
    showViewController(viewController: klatUIKitVC)
}

// 채널 식별자 값으로 채널 객체 (TPChannel) 가져오기
func getChannel(channelID:String) async -> (Bool, Error?, TPChannel?) {
    return await withCheckedContinuation { continuation in
        TalkPlus.sharedInstance()?.getChannel(channelID, success: { channel in
            continuation.resume(returning: (true, nil, channel))
        }, failure: { (errorCode, error) in
            continuation.resume(returning: (false, error, nil))
        })
    }
}

// 채팅 목록 화면 노출
func showViewController(viewController:UIViewController) {
    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let windowScene = scene.delegate as? UIWindowSceneDelegate,
       let window = windowScene.window
    {
        guard let window = window else { return }
        UIView.transition(with: window, duration: 0.5, 
                          options: .transitionCrossDissolve, animations: {
            window.rootViewController = UINavigationController(rootViewController: viewController)
        }, completion: nil)
    }
}

```

### - 채팅 화면으로 이동하기
```swift
import TalkPlus
import KlatUIKit
                
// 로그인 성공 후, 채팅 화면으로 이동하기 (채널이 이미 생성되어 채널 식별자 값이 있는 경우)
func showChatMessageViewController(channelId:String) {
    Task {
        let result = await getChannel(channelID: channelId)
        guard let channel = result.2 else { return }
        let bundle = Bundle(for: KlatChatMessageViewController.self)
        let nibName = String(describing: KlatChatMessageViewController.self)
        let klatUIKitVC = KlatChatMessageViewController(nibName: nibName, bundle: bundle)
        klatUIKitVC.chatChannel = channel
        await MainActor.run {
            showViewController(viewController: klatUIKitVC)
        }
    }
}

// 채널 식별자 값으로 채널 객체 (TPChannel) 가져오기
func getChannel(channelID:String) async -> (Bool, Error?, TPChannel?) {
    return await withCheckedContinuation { continuation in
        TalkPlus.sharedInstance()?.getChannel(channelID, success: { channel in
            continuation.resume(returning: (true, nil, channel))
        }, failure: { (errorCode, error) in
            continuation.resume(returning: (false, error, nil))
        })
    }
}

// 채팅 화면 노출
func showViewController(viewController:UIViewController) {
    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let windowScene = scene.delegate as? UIWindowSceneDelegate,
       let window = windowScene.window
    {
        guard let window = window else { return }
        UIView.transition(with: window, duration: 0.5, 
                          options: .transitionCrossDissolve, animations: {
            window.rootViewController = UINavigationController(rootViewController: viewController)
        }, completion: nil)
    }
}

```


<br />

## 작성자

Neptune Company

<br />
