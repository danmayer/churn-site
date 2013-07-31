# encoding: UTF-8
require 'json'
require 'fileutils'
require 'rack-flash'
require 'redis'
require 'rest-client'
require 'open-uri'
require 'addressable/uri'
require './lib/redis_initializer'
require './models/project'
require './models/commit'

DEFERRED_SERVER_ENDPOINT = "http://git-hook-responder.herokuapp.com/"
DEFERRED_SERVER_TOKEN    = ENV['DEFERRED_ADMIN_TOKEN']

set :public_folder, File.dirname(__FILE__) + '/public'
set :root, File.dirname(__FILE__)
enable :logging
enable :sessions
use Rack::Flash, :sweep => true

helpers do
end

before /.*/ do
  if request.host.match(/herokuapp.com/)
    redirect request.url.gsub("churn-site.herokuapp.com",'churn.picoappz.com'), 301
  end
end

get '/' do
  @projects      = Project.projects
  erb :index
end

get '/*/commits/*' do |project_path, commit|
  @project      = Project.get_project(project_path)
  @commit       = Commit.get_commit(@project.name, commit)
  erb :commit
end

get '/*' do |project_path|
  @project      = Project.get_project(project_path)
  erb :project
end

post '/' do
  push = JSON.parse(params['payload'])
  project_url = push['repository']['url']
  project_name = project_url.gsub(/.*com\//,'')
  commit = push['after']
  commit_data = push['commits'].detect{|a_commit| a_commit['id']==commit }
  if project = Project.get_project(project_name)
    project.update(push['repository'])
    project.add_commit(commit, commit_data)
    forward_to_deferred_server(project.name, commit)
  else
    project = Project.add_project(project_name, push['repository'])
    project.add_commit(commit, commit_data)
    forward_to_deferred_server(project.name, commit)
  end
end

post '/churn/*/commits/*' do |project_path, commit|
  @project      = Project.get_project(project_path)
  @commit       = Commit.get_commit(@project.name, commit)
  if @project && @commit
    forward_to_deferred_server(@project.name, @commit.name)
  else
    status 404
    body "project or commit doesn't exist!"
  end
end

private

def forward_to_deferred_server(project, commit)
  resource = RestClient::Resource.new(DEFERRED_SERVER_ENDPOINT, 
                                      :timeout => 18, 
                                      :open_timeout => 10)
  
  resource.post(:signature => DEFERRED_SERVER_TOKEN,
                :project => project,
                :commit => commit,
                :command => 'churn')
rescue RestClient::RequestTimeout
  puts "timed out during deferred-server hit"
end
