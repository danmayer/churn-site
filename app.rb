# encoding: UTF-8
require 'json'
require 'fileutils'
require 'sinatra/flash'
require 'redis'
require 'rest-client'
require 'open-uri'
require 'addressable/uri'
require 'fog'
require 'octokit'
require 'active_support/core_ext'

require './lib/redis_initializer'
require './lib/server-files'
require './models/project'
require './models/commit'


DEFERRED_SERVER_ENDPOINT = "http://git-hook-responder.herokuapp.com/"
DEFERRED_SERVER_TOKEN    = ENV['DEFERRED_ADMIN_TOKEN']
DEFERRED_CHURN_TOKEN     = ENV['DEFERRED_CHURN_TOKEN']

set :public_folder, File.dirname(__FILE__) + '/public'
set :root, File.dirname(__FILE__)
enable :logging
enable :sessions

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

post '/*/commits/*' do |project_name, commit|
  @project      = Project.get_project(project_name)
  @commit       = Commit.get_commit(@project.name, commit)
  rechurn       = params['rechurn'] || 'true'
  if @project && @commit
    project_data = Octokit.repo project_name
    gh_commit = Octokit.commits(project_name, nil, :sha => commit).first
    commit = gh_commit['sha']
    commit_data = gh_commit
    puts "sending with #rechurn #{rechurn}"
    find_or_create_project(project_name, project_data, commit, commit_data, :rechurn => rechurn)
    flash[:notice] = 'project rechurning'
    redirect "/#{@project.name}/commits/#{@commit.name}"
  else
    puts "error project #{project_name} commit #{commit}"
    flash[:error] = 'project or commit not found'
    redirect '/'
  end
end


post '/churn/*' do |project_path|
  @project      = Project.get_project(project_path)
  if @project
    forward_to_deferred_server(@project.name, 'history')
    flash[:notice] = 'project building history (refresh soon)'
    redirect "/#{@project.name}"
  else
    flash[:error] = 'project not found'
    redirect '/'
  end
end

get '/*' do |project_path|
  @project      = Project.get_project(project_path)
  if @project
    erb :project
  else
    flash[:error] = 'project not found'
    redirect '/'
  end
end

post '/projects/add' do
  project_name = params['project_name']
  if project_name
    project_data = Octokit.repo project_name
    gh_commit = Octokit.commits(project_name).first
    commit = gh_commit['sha']
    commit_data = gh_commit
    find_or_create_project(project_name, project_data, commit, commit_data)
    flash[:notice] = 'project created'
  else
    flash[:notice] = 'project name required'
  end
  redirect '/'
end

post '/' do
  push = JSON.parse(params['payload'])
  project_url = push['repository']['url']
  project_name = project_url.gsub(/.*com\//,'')
  project_data = push['repository']
  commit = push['after']
  commit_data = push['commits'].detect{|a_commit| a_commit['id']==commit }
  find_or_create_project(project_name, project_data, commit, commit_data)
end

private

def find_or_create_project(project_name, project_data, commit, commit_data, options = {})
  if project = Project.get_project(project_name)
    project.update(project_data)
    project.add_commit(commit, commit_data)
    if options[:rechurn]=='true' || commit.churn_results==Commit::MISSING_CHURN_RESULTS
      forward_to_deferred_server(project.name, commit)
    end
  else
    project = Project.add_project(project_name, project_data)
    project.add_commit(commit, commit_data)
    forward_to_deferred_server(project.name, commit)
  end
end

def deferred_request(request)
  begin
    uri = Addressable::URI.new
    uri.query_values = request.params.merge('deferred_request' => true)
    request_endpoint = "#{request.path}?#{uri.query}"
    
    resource = RestClient::Resource.new(DEFERRED_SERVER_ENDPOINT, 
                                        :timeout => 18, 
                                        :open_timeout => 10)
    
    resource.post(:signature => DEFERRED_CHURN_TOKEN,
                  :project => 'danmayer/churn-site',
                  :project_request => request_endpoint)
  rescue RestClient::RequestTimeout
    puts "Sorry, sending to deferred_request timed out"
  end
end

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
