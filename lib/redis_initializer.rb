# encoding: utf-8
require 'date'

REDIS = if ENV['RACK_ENV']=='production'
          Redis.new(:host => ENV["REDIS_HOST"], :port => ENV["REDIS_PORT"], :password => ENV["REDIS_PASSWORD"])
        elsif ENV['RACK_ENV']=='test'
          {}
        else
          Redis.new(:host => '127.0.0.1', :port => 6379)
        end

class UsageCount
  
  def self.increase
    REDIS.incr(self.counter_key)
  end

  def self.get_count
    REDIS.get(self.counter_key).to_i
  end

  def self.usage_remaining
    80 - self.get_count
  end

  def self.counter_key
    "blog2rss:usage:#{Date.today}"
  end

end
