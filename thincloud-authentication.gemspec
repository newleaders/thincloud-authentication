$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "thincloud/authentication/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "thincloud-authentication"
  s.version     = Thincloud::Authentication::VERSION
  s.authors     = ["Phil Cohen", "Robert Bousquet"]
  s.email       = ["pcohen@newleaders.com", "rbousquet@newleaders.com"]
  s.homepage    = "https://github.com/newleaders/thincloud-authentication"
  s.summary     = "Rails Engine to provide authentication for Thincloud applications"
  s.description = "Rails Engine to provide authentication for Thincloud applications"

  s.files = Dir["{app,config,db,lib}/**/*"] + %w[MIT-LICENSE Rakefile README.md]

  s.add_dependency "rails", ">= 3.2.16"
  s.add_dependency "bcrypt-ruby"
  s.add_dependency "omniauth", "~> 1.1.4"
  s.add_dependency "omniauth-identity", "~> 1.1.1"

  s.add_development_dependency "thincloud-test-rails"
end
