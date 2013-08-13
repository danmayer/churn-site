source 'http://rubygems.org'
gem 'rake'
gem 'sinatra'
gem 'json'
gem 'sinatra-flash'
gem 'redis'
gem 'rest-client'
gem 'addressable'
gem 'fog'
gem 'octokit'
gem 'i18n'
gem 'active_support'

group :production do
  gem 'unicorn'
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
