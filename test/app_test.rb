ENV['RACK_ENV'] = 'test'
require 'sinatra'
require File.expand_path(File.join(File.dirname(__FILE__), '../app'))
require 'test/unit'
require 'rack/test'
require 'mocha/setup'

class MyAppTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_root
    Project.stubs(:projects).returns([])
    get '/'
    assert_match 'churn', last_response.body
  end

  private

  def script_payload
    {:fake => 'payload'}
  end

end
