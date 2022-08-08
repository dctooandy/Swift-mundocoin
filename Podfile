# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'


def shared_pods
  use_frameworks!

  # Pods for cryptoVerOne
  pod 'RxSwift',    '~> 5.1.0'
  pod 'RxCocoa',    '~> 5.1.0'
  pod 'Toaster', :git => 'https://github.com/devxoul/Toaster.git', :branch => 'master'
  pod 'SDWebImage'
  pod 'SDWebImageSVGKitPlugin'
  pod 'KeychainSwift'
  pod 'SnapKit', '~> 4.0.0'
  pod 'Parchment', '~> 1.6.0'
  pod 'UPCarouselFlowLayout'
  pod 'Alamofire', '~> 4.8.2'
  pod 'SwiftyBeaver'
  pod 'lottie-ios'
  pod 'SwiftyJWT'
  pod 'DropDown'
  pod "ReCaptcha/RxSwift"
  pod 'OOSwitch'
  pod 'Socket.IO-Client-Swift', '~> 15.2.0'
  pod 'JWTDecode', '~> 2.6'
  pod 'Firebase/Analytics'
end

target 'cryptoVerOne_stage' do
 shared_pods
end

target 'cryptoVerOne_dev' do
 shared_pods
end

target 'cryptoVerOne' do
 shared_pods
end

target 'Approval_stage' do
 shared_pods
end

target 'Approval_dev' do
 shared_pods
end

target 'Approval' do
 shared_pods
end


post_install do |installer|
 installer.pods_project.targets.each do |target|
  target.build_configurations.each do |config|
   config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
  end
 end
end
