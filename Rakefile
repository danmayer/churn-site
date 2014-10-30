require "rubygems"
require 'rake'
require 'rake/testtask'
require 'dotenv'
DEFAULT_ENV = ENV['RACK_ENV'] || 'development'
Dotenv.load ".env.#{DEFAULT_ENV}", '.env'
require 'json'
require 'redis'
require 'coverband'

task :default => :test

desc "run tests"
task :test do
  # just run tests, nothing fancy
  Dir["test/**/*.rb"].sort.each { |test| load test }
end

desc "push env to heroku"
task :push_env do
  env_file = '.env'
  puts "pushing from #{env_file}"
  env_pairs = []
  File.read(env_file).each_line do |line|
    var, value = line.split(':').map(&:strip)
    env_pairs << "#{var}='#{value}'"
  end
  cmd = "heroku config:set #{env_pairs.join(' ')}"
  puts cmd
  puts `#{cmd}`
end

desc "generate swagger docs"
task :swagger do
  system 'bundle exec source2swagger -f app.rb -c "##~" -o public/api'
end

desc "loads env"
task :environment do
  require 'sinatra'
  require './app.rb'
end

Coverband.configure
require 'coverband/tasks'

namespace :coverband do
  desc "get coverage baseline"
  task :baseline_app do
    Coverband::Reporter.baseline {
      require 'sinatra'
      require './app.rb'
    }
  end
end

require 'resque/tasks'

task "resque:setup" do
      ENV['QUEUE'] = '*'
end