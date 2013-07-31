source 'https://rubygems.org'
gem 'rake'
gem 'sinatra'
gem 'json'
gem 'rack-flash3'
gem 'redis'

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
