require "rubygems"
require 'rake'
require 'rake/testtask'
require 'dotenv'
DEFAULT_ENV = ENV['RACK_ENV'] || 'development'
Dotenv.load ".env.#{DEFAULT_ENV}", '.env'

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
