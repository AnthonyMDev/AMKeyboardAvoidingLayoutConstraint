Pod::Spec.new do |s|
  s.name             = 'AMKeyboardAvoidingLayoutConstraint'
  s.version          = '1.1.0'
  s.summary          = "An `NSLayoutConstraint` subclass that can be pinned to the bottom layout guide and will adjust to avoid the keyboard."
  s.swift_version    = '4.2'

  s.homepage         = "https://github.com/AnthonyMDev/AMKeyboardAvoidingLayoutConstraint"
  s.license          = 'MIT'
  s.author           = { "Anthony Miller" => "AnthonyMDev@gmail.com" }
  s.source           = { :git => "https://github.com/AnthonyMDev/AMKeyboardAvoidingLayoutConstraint.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/AnthonyMDev'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'

  s.frameworks = 'UIKit'
end
