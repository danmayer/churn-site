# encoding: UTF-8
require 'json'
require 'fileutils'
require 'rack-flash'
require 'redis'
require './lib/redis_initializer'
require './models/project'
require './models/commit'

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
  else
    project = Project.add_project(project_name, push['repository'])
    project.add_commit(commit, commit_data)
  end
end

private
