require 'sinatra'
require 'coverband'

use Coverband::Middleware, :root => Dir.pwd,
          :reporter => Redis.new(:host => 'utils.picoappz.com', :port => 49182, :db => 1),
	  :ignore => ['vendor'],
	  :percentage => 60.0

require './app'

# This breaks the new passenger setup find new logging option
#log = File.new("./log/sinatra.log", "a+")
#STDOUT.reopen(log)
#STDERR.reopen(log)
$stdout.sync = true

run Sinatra::Application
