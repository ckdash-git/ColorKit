Pod::Spec.new do |s|
  s.name             = 'ColorKit'
  s.version          = '0.1.0'
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
  s.author           = { 'Your Name' => 'you@example.com' }
  s.source           = { :git => 'https://github.com/ckdash-git/ColorKit.git', :tag => s.version.to_s }
  s.platform         = :ios, '13.0'
  s.swift_version    = '5.9'
  s.source_files     = 'Sources/**/*.{swift}'
  s.requires_arc     = true
end