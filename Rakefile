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

desc "report unused lines"
task :coverband do
  baseline = JSON.parse(File.read('./tmp/coverband_baseline.json'))
  # merge more {'/Users/danmayer/projects/cover_band_server/app.rb' => Array.new(31,1)}
  root_paths = ['/app/']
  coverband_options = {:existing_coverage => baseline, :roots => root_paths}
  Coverband::Reporter.report(Redis.new(:host => 'utils.picoappz.com', :port => 49182, :db => 1), coverband_options)
end

desc "get coverage baseline"
task :coverband_baseline do
  Coverband::Reporter.baseline {
    require 'sinatra'
    require './app.rb'
  }
end
