Pod::Spec.new do |s|
  s.name         = "BUCAutoObject"
  s.version      = "2.2"
  s.summary      = "An NSObject subclass that provides implementations of NSCoding, NSSecureCoding, NSCopying, and -isEqual: based on the object's properties. Based on AutoCoding. https://github.com/nicklockwood/AutoCoding"
  s.homepage     = "https://github.com/MichaelBuckley/BUCAutoObject"
  s.license      = 'zlib'
  s.author       = "Michael Buckley"
  s.source       = { :git => "https://github.com/MichaelBuckley/BUCAutoObject", :tag => "2.2" }
  s.ios.deployment_target = '4.3'
  s.osx.deployment_target = '10.6'
  s.source_files = 'BUCAutoObject/BUCAutoObject'
end
