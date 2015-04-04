Pod::Spec.new do |s|
  s.name         = "NGTabBarController"
  s.version      = "0.0.1"
  s.license      = { :type => 'MIT', :file => 'LICENSE.md' }
  s.summary      = "A custom TabBarController which can be positioned on the bottom, top, left or top."
  s.description  = "A custom TabBarController which can be positioned on the bottom, top, left or top. Utilizes iOS 5 Containment API if possible, but works on iOS 4 too. The TabBar is fully customizable with a tintColor or background image as well as the possibility to show/hide the item highlight and the possibility to change the text colors, have image-only tabBar items etc."
  s.homepage     = "https://github.com/NOUSguide/NGTabBarController"
  s.authors      = { "Matthias Tretter" => "https://github.com/myell0w/", "Thomas Heingaertner" => "https://github.com/kampfgnu/" }
  s.source       = { :git => "https://github.com/NOUSguide/NGTabBarController.git", :tag => '0.0.1' }
  s.source_files = 'NGTabBarController/*.{h,m}'
  s.frameworks = 'Foundation', 'UIKit'
  s.requires_arc = true
  s.platform     = :ios
  s.ios.deployment_target = '4.0'
end
