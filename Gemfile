source 'http://rubygems.org'
ruby "1.9.3"
gem 'rake'
gem 'sinatra'
gem 'json'
gem 'sinatra-flash'
gem 'sinatra-contrib'
gem 'redis'
gem 'rest-client'
gem 'addressable'
gem 'fog'
gem 'octokit'
gem 'i18n'
gem 'active_support'
gem 'airbrake'
gem 'churn', '0.0.32'
gem 'dotenv-rails'
gem 'coverband', '>= 0.0.15'
gem "statsd-ruby"
gem 'source2swagger'
gem "sinatra-cross_origin"

group :production do
  gem 'unicorn'
  gem 'newrelic_rpm'
end

group :development, :test do
   gem 'rack-test'
   gem 'mocha'
end

group :development do
  gem 'shotgun'
  gem 'pry'
  gem 'leader', :git => 'git://github.com/halo/leader.git'
  gem 'foreman'
  gem "better_errors"
  gem "binding_of_caller"
end
