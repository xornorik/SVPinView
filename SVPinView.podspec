
Pod::Spec.new do |s|

  s.name         = "SVPinView"
  s.version      = "0.0.1"
  s.summary      = "SVPinView is a customisable library used for accepting alphanumeric pins or one-time passwords."

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description  = <<-DESC
                   DESC

  s.homepage     = "https://github.com/xornorik/SVPinView"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"

  s.license      = "MIT"

  s.author = { "Srinivas Vemuri" => "xornorik@gmail.com" }

  s.platform     = :ios
  s.ios.deployment_target = "9.0"

  s.source       = { :git => "https://github.com/xornorik/SVPinView.git", :tag => "#{s.version}" }
  s.source_files = "SVPinView/**/*.{swift}"

  s.resources = "SVPinView/**/*.{png,jpeg,jpg,storyboard,xib,xcassets`}"

  # s.dependency "JSONKit", "~> 1.4"

end
