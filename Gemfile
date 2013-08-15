source "https://rubygems.org"

# Declare your gem's dependencies in thincloud-authentication.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# jquery-rails is used by the dummy application
gem "jquery-rails", "~> 3.0.4"
gem "omniauth-linkedin"

gem "thincloud-test",        github: "bousquet/thincloud-test",       branch: "rails4"
gem "thincloud-test-rails",  github: "bousquet/thincloud-test-rails", branch: "rails4"

platforms :jruby do
  gem "activerecord-jdbc-adapter", require: false
end

group :test do
  platforms :ruby do
    gem "mysql2"
    gem "pg"
    gem "sqlite3"
    gem "simplecov"
  end

  platforms :jruby do
    gem "activerecord-jdbcmysql-adapter",      require: false
    gem "activerecord-jdbcpostgresql-adapter", require: false
    gem "activerecord-jdbcsqlite3-adapter",    require: false
  end
end
