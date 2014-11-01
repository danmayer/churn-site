require 'resque/errors'
require 'resque/plugins/resque_heroku_autoscaler'

if (Rails.env == 'development')
  Resque::Plugins::HerokuAutoscaler.config do |c|
    c.scaling_disabled = true
  end
end

module RetriedJob
  def on_failure_retry(e, *args)
    puts "Performing #{self} caused an exception (#{e}). Retrying..."
    $stdout.flush
    # Resque.enqueue self, *args
  end
end

class BackgroundChurn
  extend RetriedJob
  extend Resque::Plugins::HerokuAutoscaler

  attr_reader :originals_directory, :watermarked_directory, :connection, :original_file
  @queue = :churn

  def initialize(key)
    @originals_directory = ''
    @watermarked_directory = ''

    @original_file = ''
    flush "Initialized BackgroundChurn worker instance"
  end

  def self.perform(key)
    (new key).churn_project
  rescue Resque::TermException
    Resque.enqueue(self, key)
  end

  def churn_project
    REDIS.incr('background:job')
    #Dir.mktmpdir do |tmpdir|
    #  tmpfile = File.join(tmpdir, @original_file.key)
    #
    #  flush "Opening original file locally: #{tmpfile}"
    #end 
  end

  def flush(str)
    puts str
    $stdout.flush
  end
end