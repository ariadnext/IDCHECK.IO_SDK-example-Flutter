Pod::Spec.new do |s|
  s.name             = 'idcheckio'
  s.version          = '7.0.0-beta1'
  s.summary          = 'An IDCheck.io Sdk Flutter plugin.'
  s.homepage         = 'https://www.ariadnext.com/'
  s.author           = { 'ARIADNEXT' => 'team-mobile@ariadnext.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '10.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.4.2'
  s.dependency 'IDCheckIOSDK', '7.0.0-beta1'

end
