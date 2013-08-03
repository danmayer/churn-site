source 'https://rubygems.org'
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

# Prevent installation on Heroku with
# heroku config:add BUNDLE_WITHOUT="development:test"
group :development, :test do
  gem 'rack-test'
  gem 'mocha'
  gem 'shotgun'
  gem 'pry'
  gem 'leader', :git => 'git://github.com/halo/leader.git'
  gem 'foreman'
end
