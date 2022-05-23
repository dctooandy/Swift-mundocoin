# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'cryptoVerOne' do
  # Comment the next line if you don't want to use dynamic frameworks
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
end
post_install do |installer|
 installer.pods_project.targets.each do |target|
  target.build_configurations.each do |config|
   config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
  end
 end
end
