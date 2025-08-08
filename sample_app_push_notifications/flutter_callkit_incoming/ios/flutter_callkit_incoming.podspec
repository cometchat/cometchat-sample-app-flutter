#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_callkit_incoming.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_callkit_incoming'
  s.version          = '0.0.1'
  s.summary          = 'Flutter Callkit Incoming'
  s.description      = <<-DESC
Flutter Callkit Incoming
                       DESC
  s.homepage         = 'https://github.com/hiennguyen92/flutter_callkit_incoming'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Hien Nguyen' => 'hien@hiennv.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'CryptoSwift'
  s.platform = :ios, '10.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.0'
end
