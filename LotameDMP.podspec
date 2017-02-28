#
# Be sure to run `pod lib lint LotameDMP.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "LotameDMP"
  s.version          = "3.1.0"
  s.summary          = "This open source library can be leveraged by Lotame clients to collect data from within their iOS applications."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
  Data should influence everything you do – from the products and content you create, to the way you shape and execute your go-to-market strategy. Lotame’s data management platform makes this vision a reality. Our SaaS platform is used by marketers, agencies and publishers around the world to make audience data meaningful and actionable.  This framework makes it easy to plug your iOS app into the data management platform.
                       DESC

  s.homepage         = "https://github.com/Lotame/LotameDMP-IOS"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Dan Rusk" => "djrusk@gmail.com" }
  s.source           = { :git => "https://github.com/Lotame/LotameDMP-IOS.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '9.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'LotameDMP' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'AdSupport'
  s.dependency 'Alamofire', '~> 4.0'
end
