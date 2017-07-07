# Uncomment this line to define a global platform for your project

platform :ios, '10.0'
use_frameworks!

def shared_pods
    
    #---- Development Support ----#
    # Fabric Family
    pod 'Fabric'
    pod 'Crashlytics'
    
    # Mixpanel
    pod 'Mixpanel'
    
    # Aspect
    pod 'Aspects', '~> 1.4.1'
    
    # Networking
    pod 'AlamofireObjectMapper', '~> 4.0.0'
    pod 'Alamofire', '~> 4.0.1'
    pod 'SDWebImage/WebP'
    pod 'SwiftyJSON', git: 'https://github.com/BaiduHiDeviOS/SwiftyJSON.git', branch: 'swift3'
    
    # UserDefaults
    pod 'GVUserDefaults', '~> 1.0.2'
    
    # UI
    pod 'UICollectionViewLeftAlignedLayout', '~> 1.0.2'
    pod 'HPGrowingTextView', '~> 1.1'
    
    # Utility
    pod 'BlocksKit', '~> 2.2.5'
    pod 'NSDate+TimeAgo', '~> 1.0.6'
    
    # KeyChain
    pod 'SSKeychain', '~> 1.4.0'

    # Acknowledgements 
    pod 'VTAcknowledgementsViewController', '~> 1.0'

end

def create_acknowledgements
   
   #---- Create Acknowledgements ----#
   
   # http://kishikawakatsumi.hatenablog.com/entry/20140211/1392111037
   # http://qiita.com/laiso/items/47c1e32bc325549720dd
   post_install do | installer |
       require 'fileutils'
       FileUtils.cp_r('Pods/Target Support Files/Pods-PezzleHub/Pods-PezzleHub-acknowledgements.plist', 'PezzleHub/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
       
       # TODO: PerzzleStudio
       FileUtils.cp_r('Pods/Target Support Files/Pods-PerzzleStudio/Pods-PerzzleStudio-acknowledgements.plist', 'PerzzleStudio/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
   end

end

target 'PezzleHub' do
    
    shared_pods
    
end

target 'PerzzleStudio' do
    
    shared_pods
    
end

create_acknowledgements
