source 'http://rubygems.org'
ruby "2.0.0"
gem 'rake'
gem 'sinatra'
gem 'json'
gem 'sinatra-flash'
gem 'sinatra-contrib'
gem 'redis'
gem 'resque'
gem 'resque-heroku-autoscaler', git: 'https://github.com/markaschneider/resque-heroku-autoscaler.git'
gem 'rest-client'
gem 'addressable'
gem 'fog'
gem 'octokit'
gem 'i18n'
gem 'activesupport'
gem 'airbrake'
gem 'churn', '0.0.32'
gem 'dotenv-rails'
gem 'coverband', '1.0.0'
gem 'coverband_ext'
gem "statsd-ruby", :require => "statsd"
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
