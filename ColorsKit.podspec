Pod::Spec.new do |s|
  s.name             = 'ColorsKit'
  s.version          = '0.2.0'
  s.summary          = 'Advanced color management for iOS: perceptual color science, data visualization, color harmony, psychology.'
  s.description      = <<-DESC
ColorsKit provides comprehensive color management for iOS apps with advanced features:
- Hex parsing/formatting and UIKit/SwiftUI extensions
- Dynamic theming with dark/light adaptation
- Accessibility contrast checking and color-blindness simulation
- Data visualization palettes (Viridis, Plasma, scientific colormaps)
- Perceptual color mathematics (Delta E, color space conversions)
- Color harmony generation (complementary, analogous, triadic)
- Advanced color blending modes (multiply, screen, overlay, etc.)
- Color psychology engine for emotion-based color selection
- Temperature gradients and thermal imaging colors
- Professional gradient builders and palette generators
  DESC
  s.homepage         = 'https://github.com/ckdash-git/ColorsKit'
  s.license          = { :type => 'Apache-2.0', :file => 'LICENSE' }
  s.author           = { 'Chandan Kumar Dash' => 'chandan@optionallabs.com' }
  s.source           = { :git => 'https://github.com/ckdash-git/ColorsKit.git', :tag => s.version.to_s }
  s.swift_version    = '5.9'
  s.ios.deployment_target    = '13.0'
  s.osx.deployment_target    = '12.0'
  s.source_files     = 'Sources/**/*.{swift}'
  s.requires_arc     = true
  s.module_name      = 'ColorsKit'
  s.documentation_url = 'https://raw.githubusercontent.com/ckdash-git/ColorsKit/main/README.md'
end