#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_huaji_push.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_huaji_push'
  s.version          = '1.0.11'
  s.summary          = 'A new Flutter plugin.'
  s.description      = <<-DESC
A new Flutter plugin.
                       DESC
  s.homepage         = 'https://github.com/wskkhn-hezhong/flutter_huaji_push.git'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'huaji' => 'wskkhn001@gmail.com' }
  s.source           = { :git => "https://github.com/wskkhn-hezhong/flutter_huaji_push.git", :branch => "V1.0.11" }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'TPNS-iOS'
  s.platform = :ios, '10.0'
  s.static_framework = true

end
