Pod::Spec.new do |s|

    s.name              = "CBToolkit"
    s.version           = "0.0.1"
    s.summary           = "A UI Toolkit for iOS"
    s.homepage          = "https://github.com/WCByrne/CBToolki"
    s.license           = "MIT"
  
    s.author            = { "wes" => "wesburn@me.com" }
    s.source            = {
        :git => "https://github.com/WCByrne/CBToolkit.git",
        :tag => s.version.to_s
    }

    s.platform          = :ios, '7.0'
    s.source_files      = 'CBToolkit/CBToolkit/*.{swift}'
    s.requires_arc      = true


end