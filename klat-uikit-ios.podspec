Pod::Spec.new do |s|
  s.name = "klat-uikit-ios"
  s.version = "1.0.0"
  s.summary = "Klat UIKit SDK for iOS"
  s.license = {
    :type => 'MIT',
    :text => 'Neptune Company. All rights Reserved.'
  }
  s.author = "Neptune Company"
  s.homepage = "https://www.klat.kr"
  s.description = "Klat UIKit SDK for iOS"
  s.source = { :git => 'https://github.com/adxcorp/klat-uikit-ios-release.git', :tag => s.version.to_s }
  s.ios.deployment_target = '13.0'
  s.ios.vendored_framework = 'ios/KlatUIKit.xcframework'
  s.dependency 'talkplus-ios', '>= 1.0.1'
end