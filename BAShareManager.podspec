Pod::Spec.new do |s|
s.name         = "BAShareManager"
s.version      = "1.0.0"
s.summary      = '自定义友盟分享和友盟登陆，可以单个调用，也可以列表调用！'
s.homepage     = "https://github.com/boai/BAShareManager.git"
s.license      = { :type => 'MIT', :file => 'LICENSE' }
s.authors      = { "boai" => "sunboyan@outlook.com" }
s.social_media_url   = "http://weibo.com/538298123?refer_flag=1001030101_&is_all=1"
s.homepage     = 'https://github.com/boai/BAShareManager.git'
s.platform     = :ios, "6.0"
s.source       = { :git => "https://github.com/boai/BAShareManager.git", :tag => s.version.to_s }

s.requires_arc = true
s.source_files = 'BAShareManager/**/*.{h,m}'
s.public_header_files = 'BAShareManager/**/*.{h}'

end
