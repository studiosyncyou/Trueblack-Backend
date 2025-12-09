source "https://rubygems.org"

gem "rails", "~> 8.0.3"
gem "pg", ">= 1.1"
gem "puma", ">= 5.0"

gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "bootsnap", require: false

gem "kamal", require: false

gem "thruster", require: false

gem "bcrypt", "~> 3.1.7"

# Authentication
gem "jwt"
gem "twilio-ruby"

# HTTP client for Rista API
gem "httparty"

gem "graphql"
gem "graphiql-rails"

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "faker"
  gem "solid_cache"
  gem "solid_queue"
end
