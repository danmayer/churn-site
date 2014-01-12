require 'sinatra'
require 'coverband'

Coverband.configure do |config|
  config.root              = Dir.pwd
  config.redis             = Redis.new(:host => 'utils.picoappz.com', :port => 49182, :db => 1)
  config.root_paths        = ['/app/']
  config.ignore            = ['vendor']
  config.percentage        = 60.0
  # config.stats             = statsd
  config.verbose           = true
end

use Coverband::Middleware

require './app'

# This breaks the new passenger setup find new logging option
#log = File.new("./log/sinatra.log", "a+")
#STDOUT.reopen(log)
#STDERR.reopen(log)
$stdout.sync = true

run Sinatra::Application
