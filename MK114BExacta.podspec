#
# Be sure to run `pod lib lint MK114BExacta.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MK114BExacta'
  s.version          = '0.1.0'
  s.summary          = 'A short description of MK114BExacta.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/aadyx2007@163.com/MK114BExacta'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'aadyx2007@163.com' => 'aadyx2007@163.com' }
  s.source           = { :git => 'https://github.com/aadyx2007@163.com/MK114BExacta.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '12.0'
  
  s.resource_bundles = {
    'MK114BExacta' => ['MK114BExacta/Assets/*.png']
  }

  s.subspec 'ApplicationModule' do |ss|
    ss.source_files = 'MK114BExacta/Classes/ApplicationModule/**'
    ss.dependency 'MKBaseModuleLibrary'
  end
  
  s.subspec 'CTMediator' do |ss|
    ss.source_files = 'MK114BExacta/Classes/CTMediator/**'
    
    s.dependency 'CTMediator'
  end
  
  s.subspec 'SDK-BML' do |ss|
    ss.source_files = 'MK114BExacta/Classes/SDK-BML/**'
    
    ss.dependency 'MKBaseBleModule'
  end
  
  s.subspec 'Target' do |ss|
    ss.source_files = 'MK114BExacta/Classes/Target/**'
    
    ss.dependency 'MK114BExacta/Functions'
  end
  
  s.subspec 'Functions' do |ss|
    
    ss.subspec 'AboutPage' do |sss|
      sss.subspec 'Controller' do |ssss|
        ssss.source_files = 'MK114BExacta/Classes/Functions/AboutPage/Controller/**'
        
        ssss.dependency 'MK114BExacta/Functions/AboutPage/Model'
        ssss.dependency 'MK114BExacta/Functions/AboutPage/View'
      end
      sss.subspec 'Model' do |ssss|
        ssss.source_files = 'MK114BExacta/Classes/Functions/AboutPage/Model/**'
      end
      sss.subspec 'View' do |ssss|
        ssss.source_files = 'MK114BExacta/Classes/Functions/AboutPage/View/**'
        
        ssss.dependency 'MK114BExacta/Functions/AboutPage/Model'
      end
    end
    
    ss.subspec 'DeviceInfo' do |sss|
      sss.subspec 'Controller' do |ssss|
        ssss.source_files = 'MK114BExacta/Classes/Functions/DeviceInfo/Controller/**'
        ssss.dependency 'MK114BExacta/Functions/DeviceInfo/Model'

      end
      sss.subspec 'Model' do |ssss|
        ssss.source_files = 'MK114BExacta/Classes/Functions/DeviceInfo/Model/**'
      end
    end
    
    ss.subspec 'EnergyPage' do |sss|
      sss.subspec 'Controller' do |ssss|
        ssss.source_files = 'MK114BExacta/Classes/Functions/EnergyPage/Controller/**'
        
        ssss.dependency 'MK114BExacta/Functions/EnergyPage/Model'
        ssss.dependency 'MK114BExacta/Functions/EnergyPage/View'
        
        ssss.dependency 'MK114BExacta/Functions/DeviceInfo/Controller'
      end
      sss.subspec 'Model' do |ssss|
        ssss.source_files = 'MK114BExacta/Classes/Functions/EnergyPage/Model/**'
      end
      sss.subspec 'View' do |ssss|
        ssss.source_files = 'MK114BExacta/Classes/Functions/EnergyPage/View/**'
      end
    end
    
    ss.subspec 'ModifyDataPage' do |sss|
      sss.subspec 'Controller' do |ssss|
        ssss.source_files = 'MK114BExacta/Classes/Functions/ModifyDataPage/Controller/**'
      end
    end
    
    ss.subspec 'ModifyPowerStatusPage' do |sss|
      sss.subspec 'Controller' do |ssss|
        ssss.source_files = 'MK114BExacta/Classes/Functions/ModifyPowerStatusPage/Controller/**'
      end
    end
    
    ss.subspec 'PowerPage' do |sss|
      sss.subspec 'Controller' do |ssss|
        ssss.source_files = 'MK114BExacta/Classes/Functions/PowerPage/Controller/**'
        
        ssss.dependency 'MK114BExacta/Functions/PowerPage/Model'
        ssss.dependency 'MK114BExacta/Functions/PowerPage/View'
        
        ssss.dependency 'MK114BExacta/Functions/DeviceInfo/Controller'
      end
      sss.subspec 'Model' do |ssss|
        ssss.source_files = 'MK114BExacta/Classes/Functions/PowerPage/Model/**'
      end
      sss.subspec 'View' do |ssss|
        ssss.source_files = 'MK114BExacta/Classes/Functions/PowerPage/View/**'
      end
    end
    
    ss.subspec 'ScanPage' do |sss|
      sss.subspec 'Controller' do |ssss|
        ssss.source_files = 'MK114BExacta/Classes/Functions/ScanPage/Controller/**'
        
        ssss.dependency 'MK114BExacta/Functions/ScanPage/View'
        
        ssss.dependency 'MK114BExacta/Functions/AboutPage/Controller'
        ssss.dependency 'MK114BExacta/Functions/TabBarPage/Controller'
      end
      sss.subspec 'View' do |ssss|
        ssss.source_files = 'MK114BExacta/Classes/Functions/ScanPage/View/**'
      end
    end
    
    ss.subspec 'SettingPage' do |sss|
      sss.subspec 'Controller' do |ssss|
        ssss.source_files = 'MK114BExacta/Classes/Functions/SettingPage/Controller/**'
        
        ssss.dependency 'MK114BExacta/Functions/SettingPage/Model'
        ssss.dependency 'MK114BExacta/Functions/SettingPage/View'
        
        ssss.dependency 'MK114BExacta/Functions/DeviceInfo/Controller'
        ssss.dependency 'MK114BExacta/Functions/ModifyDataPage/Controller'
        ssss.dependency 'MK114BExacta/Functions/ModifyPowerStatusPage/Controller'
        ssss.dependency 'MK114BExacta/Functions/UpdatePage/Controller'
      end
      sss.subspec 'Model' do |ssss|
        ssss.source_files = 'MK114BExacta/Classes/Functions/SettingPage/Model/**'
      end
      sss.subspec 'View' do |ssss|
        ssss.source_files = 'MK114BExacta/Classes/Functions/SettingPage/View/**'
      end
    end
    
    ss.subspec 'TabBarPage' do |sss|
      sss.subspec 'Controller' do |ssss|
        ssss.source_files = 'MK114BExacta/Classes/Functions/TabBarPage/Controller/**'
        
        ssss.dependency 'MK114BExacta/Functions/PowerPage/Controller'
        ssss.dependency 'MK114BExacta/Functions/EnergyPage/Controller'
        ssss.dependency 'MK114BExacta/Functions/TimerPage/Controller'
        ssss.dependency 'MK114BExacta/Functions/SettingPage/Controller'
      end
    end
    
    ss.subspec 'TimerPage' do |sss|
      sss.subspec 'Controller' do |ssss|
        ssss.source_files = 'MK114BExacta/Classes/Functions/TimerPage/Controller/**'
        
        ssss.dependency 'MK114BExacta/Functions/TimerPage/Model'
        ssss.dependency 'MK114BExacta/Functions/TimerPage/View'
        
        ssss.dependency 'MK114BExacta/Functions/DeviceInfo/Controller'
      end
      sss.subspec 'Model' do |ssss|
        ssss.source_files = 'MK114BExacta/Classes/Functions/TimerPage/Model/**'
      end
      sss.subspec 'View' do |ssss|
        ssss.source_files = 'MK114BExacta/Classes/Functions/TimerPage/View/**'
      end
    end
    
    ss.subspec 'UpdatePage' do |sss|
      sss.subspec 'Controller' do |ssss|
        ssss.source_files = 'MK114BExacta/Classes/Functions/UpdatePage/Controller/**'
        
        ssss.dependency 'MK114BExacta/Functions/UpdatePage/Model'
      end
      sss.subspec 'Model' do |ssss|
        ssss.source_files = 'MK114BExacta/Classes/Functions/UpdatePage/Model/**'
      end
      
      sss.dependency 'iOSDFULibrary'
      
    end
    
    ss.dependency 'MK114BExacta/SDK-BML'
    ss.dependency 'MK114BExacta/CTMediator'
    
    ss.dependency 'MKBaseModuleLibrary'
    ss.dependency 'MKCustomUIModule'
    ss.dependency 'HHTransition'
    ss.dependency 'MLInputDodger'
    
  end
  
end
