$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "weixin"
  s.version     = WeiXin::VERSION
  s.authors     = ["francis jiang"]
  s.email       = ["jhjguxin@gmail.com"]
  s.homepage    = "https://github.com/jhjguxin/weixin"
  s.summary     = "A wrapper for WeiXin API"
  s.description = "A wrapper for WeiXin API"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]

  #s.add_dependency "rails", "~> 3.1.0"
  #s.add_dependency "oauth2", "~> 0.5.1"
  s.add_dependency "sinatra"
  s.add_dependency "activeresource"
  s.add_dependency "data_mapper"
  s.add_dependency "dm-sqlite-adapter"
  #s.add_development_dependency "rspec-rails"
  s.add_development_dependency "byebug"
  s.add_development_dependency "thin"
end
