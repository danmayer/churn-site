require 'resque/errors'

module RetriedJob
  def on_failure_retry(e, *args)
    puts "Performing #{self} caused an exception (#{e}). Retrying..."
    $stdout.flush
    Resque.enqueue self, *args
  end
end

class BackgroundChurn
  extend RetriedJob

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
    statsd = Statsd.new('utils.picoappz.com', 8125)
    statsd.increment 'churned.project'
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