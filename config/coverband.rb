require 'json'

baseline = if File.exist?('./tmp/coverband_baseline.json')
  JSON.parse(File.read('./tmp/coverband_baseline.json'))
else
  {}
end

Coverband.configure do |config|
  config.root              = Dir.pwd
  if defined? Redis
    config.redis             = Redis.new(:host => 'utils.picoappz.com', :port => 49182, :db => 1)
  end
  config.coverage_baseline = baseline
  config.root_paths        = ['/app/']
  config.ignore            = ['vendor']
  config.percentage        = 60.0
  if defined? Statsd
    config.stats             = Statsd.new('utils.picoappz.com', 8125)
  end
  config.verbose           = true
end
