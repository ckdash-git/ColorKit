Pod::Spec.new do |s|
  s.name             = 'ColorsKit'
  s.version          = '0.1.1'
  s.summary          = 'Comprehensive color management for iOS: hex APIs, theming, accessibility, gradients.'
  s.description      = <<-DESC
ColorKit simplifies color usage in iOS apps by providing:
- Hex parsing/formatting
- UIKit/SwiftUI extensions
- Dynamic theming with dark/light adaptation
- Accessibility contrast checking
- Palette generators and gradient builders
- Color-blindness simulation tools
  DESC
  s.homepage         = 'https://github.com/ckdash-git/ColorKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Chandan Kumar Dash' => 'chandan@optionallabs.com' }
  s.source           = { :git => 'https://github.com/ckdash-git/ColorKit.git', :tag => s.version.to_s }
  s.swift_version    = '5.9'
  s.ios.deployment_target    = '13.0'
  s.osx.deployment_target    = '12.0'
  s.source_files     = 'Sources/**/*.{swift}'
  s.requires_arc     = true
  s.module_name      = 'ColorKit'
  s.documentation_url = 'https://github.com/ckdash-git/ColorKit#readme'
end