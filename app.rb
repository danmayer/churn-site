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
require 'airbrake'

require './lib/rack_catcher'
require './lib/redis_initializer'
require './lib/server-files'
require './models/project'
require './models/commit'


DEFERRED_SERVER_ENDPOINT = "http://git-hook-responder.herokuapp.com/"
DEFERRED_SERVER_TOKEN    = ENV['DEFERRED_ADMIN_TOKEN']
DEFERRED_CHURN_TOKEN     = ENV['DEFERRED_CHURN_TOKEN']
Octokit.client_id        = ENV['DS_GH_Client_ID']
Octokit.client_secret    = ENV['DS_GH_Client_Secret']

set :public_folder, File.dirname(__FILE__) + '/public'
set :root, File.dirname(__FILE__)
enable :logging
enable :sessions

configure :development do
  require "better_errors"
  use BetterErrors::Middleware
  BetterErrors.application_root = File.dirname(__FILE__)
end

configure :production do
  require 'newrelic_rpm'
  Airbrake.configure do |config|
    config.api_key = ENV['ERRBIT_API_KEY']
    config.host    = ENV['ERRBIT_HOST']
    config.port    = 80
    config.secure  = config.port == 443
  end
  use Rack::Catcher
  use Airbrake::Rack
  set :raise_errors, true
end

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
  if @project && commit
    project_data = Octokit.repo project_name
    gh_commit = Octokit.commits(project_name, nil, :sha => commit).first
    commit = gh_commit['sha']
    commit_data = gh_commit
    puts "sending commit #{commit} with rechurn #{rechurn}"
    find_or_create_project(project_name, project_data, commit, commit_data, :rechurn => rechurn)
    flash[:notice] = 'project rechurning'
    if rechurn=='false'
      "success"
    else
      redirect "/#{@project.name}/commits/#{@commit.name}"
    end
  else
    puts "error project #{project_name} commit #{commit}"
    flash[:error] = 'project or commit not found'
    redirect '/'
  end
end


post '/churn/*' do |project_path|
  @project      = Project.get_project(project_path)
  if @project
    begin
      forward_to_deferred_server(@project.name, 'history')
      flash[:notice] = 'project building history (refresh soon)'
    rescue RestClient::InternalServerError => error
      puts "error on #{project_path} error #{error}"
      flash[:error] = 'error creating project history, try again'
    end
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
    begin
      project_data = Octokit.repo project_name
      gh_commit = Octokit.commits(project_name).first
      commit = gh_commit['sha']
      commit_data = gh_commit
      find_or_create_project(project_name, project_data, commit, commit_data)
      flash[:notice] = 'project created'
    rescue Octokit::NotFound
      flash[:notice] = "project not found try without full url or initial slash EX:'danmayer/churn'"
      redirect '/'
    end
  else
    flash[:notice] = 'project name required'
    redirect '/'
  end
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
    if options[:rechurn]==nil || options[:rechurn]=='true'
      puts "forwarding commit to deffered_server #{commit}"
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

def forward_to_deferred_server(project, commit, options = {})
  request_timeout = options.fetch(:timeout){ 6 }
  request_open_timeout    = options.fetch(:open_timeout){ 6 }
  resource = RestClient::Resource.new(DEFERRED_SERVER_ENDPOINT, 
                                      :timeout => request_timeout, 
                                      :open_timeout => request_open_timeout)
  
  resource.post(:signature => DEFERRED_SERVER_TOKEN,
                :project => project,
                :commit => commit,
                :command => 'churn')
rescue RestClient::RequestTimeout
  puts "timed out during deferred-server hit"
end
