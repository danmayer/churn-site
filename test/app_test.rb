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

  def test_commit_show
    project_name = '/danmayer/churn-site'
    churn_results = stub('churn_result', :exists? => false)
    project = stub('project', :name => project_name)
    commit  = stub('commit', :name => '4f4d3ee27d1722cb71e8237b8e48bf475fc3b7c6',
                   :project_name => project_name,
                   :commit => '4f4d3ee27d1722cb71e8237b8e48bf475fc3b7c6',
                   :message => 'fake message',
                   :author => 'Bruce Wayne',
                   :formatted_commit_time => 'time',
                   :churn_results => churn_results)
    Project.stubs(:get_project).returns(project)
    Commit.stubs(:get_commit).returns(commit)
    get '/danmayer/churn-site/commits/4f4d3ee27d1722cb71e8237b8e48bf475fc3b7c6'
    assert_match 'danmayer/churn-site', last_response.body
  end

  private

  def script_payload
    {:fake => 'payload'}
  end

end
