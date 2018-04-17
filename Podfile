# Uncomment the next line to define a global platform for your project
platform :ios, '9.3'
use_frameworks!

target 'Checkin' do
    
    # Pods for Checkin
    
    pod 'Alamofire', '~> 4.0'
    pod 'RealmSwift'
    pod 'Locksmith'
    pod 'GradientCircularProgress', :git => 'https://github.com/keygx/GradientCircularProgress', :tag=>'3.8.0'	

end


post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.0'
        end
    end
end
