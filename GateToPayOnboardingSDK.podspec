Pod::Spec.new do |s|
  s.name             = 'GateToPayOnboardingSDK'
  s.version          = '0.1.9'
  s.summary          = 'iOS SDK for easy onboarding, KYC, liveness check, and identity verification'

  s.description      = <<-DESC
GateToPayOnboardingSDK is an iOS SDK designed to simplify customer onboarding.
It supports:
- KYC data submission
- Liveness check and selfie verification
- Document capture (ID, Passport, Driving License)
- Identity verification and risk forms
DESC

  s.homepage         = 'https://github.com/SedraPay/Gate-to-Pay-Onboarding-SDK'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'SedraPay' => 'mob@sedrapay.com' }
  s.source           = { :git => 'https://github.com/SedraPay/Gate-to-Pay-Onboarding-SDK.git', :tag => s.version.to_s }

  s.swift_version      = '5.3'
  s.ios.deployment_target = '11.0'
  s.static_framework = false

  # Framework
  s.vendored_frameworks = 'GateToPayOnboardingSDK.xcframework'
  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }

  # Dependencies
  s.frameworks = 'UIKit', 'AVFoundation', 'Foundation', 'AVKit'
  s.dependency 'Alamofire'
  s.dependency 'GoogleMLKit/FaceDetection'
  s.dependency 'lottie-ios'

  # Keywords for search optimization
  s.keywords = 'GateToPay, onboarding, KYC, identity verification, iOS SDK, document capture, liveness check, Swift'
end
