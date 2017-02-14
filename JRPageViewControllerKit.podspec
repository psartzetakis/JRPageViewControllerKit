#
# Be sure to run `pod lib lint JRPageViewControllerKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'JRPageViewControllerKit'
  s.version          = '0.5.0'
  s.summary          = 'JRPageViewControllerKit take cares all the boiler blate that is needed for PageViewController '

#   s.description      = <<-DESC
# TODO: Add long description of the pod here.
#                        DESC

  s.homepage         = 'https://github.com/psartzetakis/JRPageViewControllerKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Panagiotis Sartzetakis' => 'panos@sartzetakis.me' }
  s.source           = { :git => 'https://github.com/psartzetakis/JRPageViewControllerKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.source_files = 'Source/*.swift'
  s.platform = :ios, '8.0'
  s.requires_arc = true
end
