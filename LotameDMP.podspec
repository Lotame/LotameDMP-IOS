Pod::Spec.new do |s|
  s.name             = "LotameDMP"
  s.version          = "5.0.0"
  s.summary          = "This open source library can be leveraged by Lotame clients to collect data from within their iOS applications."

  s.description      = <<-DESC
  Data should influence everything you do – from the products and content you create, to the way you shape and execute your go-to-market strategy. Lotame’s data management platform makes this vision a reality. Our SaaS platform is used by marketers, agencies and publishers around the world to make audience data meaningful and actionable.  This framework makes it easy to plug your iOS app into the data management platform.
                       DESC

  s.homepage         = "https://github.com/Lotame/LotameDMP-IOS"
  s.license          = 'MIT'
  s.author           = { "Dan Rusk" => "djrusk@gmail.com" }
  s.source           = { :git => "https://github.com/Lotame/LotameDMP-IOS.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.swift_versions  = '5.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'

  s.frameworks = 'AdSupport'
end
