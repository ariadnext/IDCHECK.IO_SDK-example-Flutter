Pod::Spec.new do |s|
  s.name             = 'idcheckio'
  s.version          = '7.1.0'
  s.summary          = 'An IDCheck.io Sdk Flutter plugin.'
  s.homepage         = 'https://www.ariadnext.com/'
  s.author           = { 'ARIADNEXT' => 'team-mobile@ariadnext.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '10.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.7'
  s.dependency 'IDCheckIOSDK', '7.1.0'
end
