Pod::Spec.new do |s|
  s.name             = 'JRPageViewControllerKit'
  s.version          = '1.1.0'
  s.summary          = 'JRPageViewControllerKit wraps all the boilerplate code that is required for the implementation of `UIPageViewController`. '

  s.homepage         = 'https://github.com/psartzetakis/JRPageViewControllerKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = 'Panagiotis Sartzetakis'
  s.source           = { :git => 'https://github.com/psartzetakis/JRPageViewControllerKit.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/SartzetakisP'

  s.source_files = 'Source/*.swift'
  s.platform = :ios, '8.0'
  s.requires_arc = true
end
