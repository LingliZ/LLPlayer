Pod::Spec.new do |s|
s.name         = "LLPlayer"
s.version      = "0.0.8"
s.summary      = "LLPlayer."
s.homepage     = "https://github.com/tuyuan2012/LLPlayer"
s.license      = "MIT"
s.author       = { "Tony" => "845384699@qq.com" }
s.platform     = :ios, "7.0"
s.source       = { :git => "https://github.com/tuyuan2012/LLPlayer.git", :tag => s.version }
s.source_files = 'LLPlayer/**/*.{h,m}'
s.vendored_libraries = ['LLPlayer/PlayerSDK.framework']
s.resource     = 'LLPlayer/PlayerSDK.bundle'
s.frameworks = "UIKit", "Foundation", "PlayerSDK"
s.requires_arc = true
s.dependency "SDWebImage"
end
