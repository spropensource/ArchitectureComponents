Pod::Spec.new do |s|
  s.name         = "ArchitectureComponents"
  s.version      = "0.1.0"
  s.summary      = "A port of Android Architecture Components to iOS."

  s.description  = <<-DESC
      Provide Lifecycle, LiveData, and other Android Architecture Components on 
      iOS. Since iOS lacks a first-party application architecture and Android 
      now has a very nice first-party application architecture, it seems 
      reasonable to adopt Android's architecture on both platforms in instances 
      when app delivery would benefit from sharing an app architecture. 
  DESC

  s.homepage = "https://github.com/spropensource/ArchitectureComponents"
  s.license = { :type => "Apache License, Version 2.0", :file => "LICENSE" }
  s.authors = { 
      "David Kinney" => "david.kinney@spr.com" 
  }
  s.platform = :ios, "10.0"
  s.source = { :git => "https://github.com/spropensource/ArchitectureComponents.git", :tag => "#{s.version}" }
  s.source_files = "Sources/**/*.swift"
end
