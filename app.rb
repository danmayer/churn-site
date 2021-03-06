# encoding: UTF-8
require 'json'
require 'fileutils'
require 'sinatra/flash'
require 'sinatra/contrib'
require 'redis'
require 'resque'
require 'rest-client'
require 'open-uri'
require 'addressable/uri'
require 'fog'
require 'octokit'
require 'active_support/core_ext'
require 'airbrake'
require 'dotenv'
require 'sinatra/cross_origin'

DEFAULT_ENV = ENV['RACK_ENV'] || 'development'
Dotenv.load ".env.#{DEFAULT_ENV}", '.env'

require './lib/rack_catcher'
require './lib/redis_initializer'
require './lib/server-files'
require './lib/background_churn'
require './models/project'
require './models/commit'
require './models/churn_result'

DEFERRED_SERVER_ENDPOINT = "http://git-hook-responder.herokuapp.com/"
DEFERRED_SERVER_TOKEN    = ENV['DEFERRED_ADMIN_TOKEN']
DEFERRED_CHURN_TOKEN     = ENV['DEFERRED_CHURN_TOKEN']
Octokit.client_id        = ENV['DS_GH_Client_ID']
Octokit.client_secret    = ENV['DS_GH_Client_Secret']

set :run, false if defined?(SKIP_SERVER)
set :public_folder, File.dirname(__FILE__) + '/public'
set :root, File.dirname(__FILE__)
enable :logging
enable :sessions

set :allow_origin, :any
set :allow_methods, [:get, :post, :options]
set :allow_credentials, true
set :max_age, "1728000"
set :expose_headers, ['Content-Type']

use Rack::Session::Cookie, key: 'churnsite',
    path: '/',
    expire_after: 24400,
    secret: (ENV['DS_GH_Client_Secret'] || 'dev')

configure :development do
  require "better_errors"
  use BetterErrors::Middleware
  BetterErrors.application_root = File.dirname(__FILE__)
  enable :cross_origin
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
  enable :cross_origin
end

helpers do

  def partial template
    erb template, :layout => false
  end

end

before /.*/ do
  redirect "index.html", 301
  if request.host.match(/herokuapp.com/)
    redirect request.url.gsub("churn-site.herokuapp.com",'churn.picoappz.com'), 301
  end

  if request.url.match(/.json$/)
    request.accept.unshift('application/json')
    request.path_info = request.path_info.gsub(/.json$/,'')
  end

end

## swaggerBase = "http://localhost:9292"
##~ swaggerBase = "http://churn.picoappz.com"
##~ root = source2swagger.namespace("api-docs")
##~ root.swaggerVersion = "1.2"
##~ root.apiVersion = "1.0"
##~ root.info = {title: "Churn API", description: "This api generates code churn reports to find volatile code in your project.", termsOfServiceUrl: "https://raw2.github.com/danmayer/churn-site/master/license.txt", contact: "danmayer@gmail.com", license: "MIT", licenseUrl: "https://raw2.github.com/danmayer/churn-site/master/license.txt"}
##~ root.apis.add :path => "/churn", :description => "A churn code metrics api"

##~ s = source2swagger.namespace("churn")
##~ s.basePath =  swaggerBase
##~ s.swaggerVersion = "1.2"
##~ s.apiVersion = "1.0"
##~ s.produces = ["application/json"]
##~ s.resourcePath = "/index"

## models
##~ s.models["MinProject"] = {:id => "MinProject", :properties => {:name => {:type => "string"}, :project_url => {:type => "string"}}}
##
##~ s.models["CommitUrl"] = {:id => "CommitUrl", :properties => {:commit_url => {:type => "string"}}}
##
##~ s.models["Project"] = {:id => "Project", :properties => {:name => {:type => "string"}, :commits => {:type => "array", :items => {"$ref" => "CommitUrl"}}}}
##
## s.models["FileChange"] = {:id => "FileChange", :properties => {:id => {:type => "string"}, :file_path => {:type => "string"}, :times_changed => {:type => "integer"}}}
##
## s.models["Churn"] = {:id => "Churn", :properties => {:id => {:type => "string"}, :changes => {"array" => {:items => { "$ref" => "FileChange"}}}}}
##
## s.models["ChurnResults"] = {:id => "ChurnResults", :properties => {:id => {:type => "string"}, :churn => {:type => "Churn"}}}
##
##~ s.models["Commit"] = {:id => "Commit", :properties => {:name => {:type => "string"}, :project_name => {:type => "string"}, :churn_results => {:type => "string"}}}

# redict to documentation index file
get '/docs/?' do
  redirect '/docs/index.html'
end

# returns the api docs for the resource listing
get '/api-docs/?', :provides => [:json] do
  res = File.read(File.join('public', 'api', 'api-docs.json'))
  body res
  status 200
end

# returns the api docs for each path
get '/api-docs/:api', :provides => [:json] do
  if File.exists?(File.join('public', 'api', "#{params[:api].to_s}.json"))
    res = File.read(File.join('public', 'api', "#{params[:api].to_s}.json"))
    body res
    status 200
  else
    body = "api endpoint doesn't exist"
    status 404
  end
end

##~ a = s.apis.add
##~ a.set :path => "/index", :produces => ["application/json"], :description => "Collection of churned projects."
##
##~ op = a.operations.add
##~ op.type = "array"
##~ op.items = { "$ref" => "MinProject"}
##
##~ op.set :method => "GET", :summary => "Returns all of the churn projects.", :deprecated => false, :nickname => "list_churn"
##~ op.summary = "Returns a list of all the churn projects"

["/", "/index"].each do |path|
  get path, :provides => [:html, :json] do
    @projects = Project.projects
    respond_to do |format|
      format.json {
        Project.projects_as_json(@projects, request)
      }
      format.html { erb :index }
    end
  end
end

get '/about' do
  Resque.enqueue(BackgroundChurn, 'about')
  erb :about
end

get '/instructions' do
  erb :instructions
end

##~ a = s.apis.add
##~ a.set :path => "/{projectPath}/commits/{commitId}", :produces => ["application/json"], :description => "Access to a projects single commit data"
##
##~ op = a.operations.add
##~ op.type = "array"
##~ op.items = { "$ref" => "Commit"}
##~ op.set :method => "GET", :deprecated => false, :nickname => "get_project_commit"
##~ op.summary = "Returns a single commit by commit id and project_path"
##~ op.parameters.add :name => "projectPath", :description => "The project_name for which this commit belongs to", :type => "string", :required => true, :paramType => "path"
##~ op.parameters.add :name => "commitId", :description => "The commit id which points to this commit data", :type => "string", :required => true, :paramType => "path"
get '/*/commits/*', :provides => [:html, :json] do |project_path, commit|
  @project      = Project.get_project(project_path)
  @commit       = Commit.get_commit(@project.name, commit) if @project
  if @project && @commit
    respond_to do |format|
      format.json { @commit.as_hash(request).to_json }
      format.html { erb :commit }
    end
  elsif @project
    flash[:error] = 'project commit not found'
    redirect "/#{@project.name}/"
  else
    flash[:error] = 'project for the commit not found'
    redirect "/"
  end
end

post '/*/commits/*' do |project_name, commit|
  @project      = Project.get_project(project_name)
  @commit       = Commit.get_commit(@project.name, commit)
  rechurn       = params['rechurn'] || 'true'
  if @project && commit
    project_data = Octokit.repo project_name
    begin
      gh_commit = Octokit.commits(project_name, nil, :sha => commit).first
    rescue Octokit::NotFound, Octokit::BadGateway
      msg = "commit not found, likely not on master branch (currently only supports master branch)"
      flash[:error] = msg
      redirect '/'
    end
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

##~ a = s.apis.add
##~ a.set :path => "/churn/{project_path}", :produces => ["application/json"], :description => "Starts generating churn report against HEAD of project_path"
##
##~ op = a.operations.add
##~ op.type = "Project"
##~ op.set :method => "POST", :deprecated => false, :nickname => "churn_project"
##~ op.summary = "Starts generating churn report against HEAD of project_path"
##~ op.parameters.add :name => "project_path", :description => "The project_name for which a churn report will be generated against", :type => "string", :allowMultiple => false, :required => true, :paramType => "path"
##~ op.parameters.add :name => "existing", :description => "If we only need to add commit data as the report already exists", :type => "string", :allowMultiple => false, :required => false, :paramType => "query"
post '/churn/*', :provides => [:html, :json] do |project_path|
  @project      = Project.get_project(project_path)
  if @project
    begin
      if params['existing']=='true'
        commits = @project.sorted_commits.map{|commit| commit.name }
        forward_to_deferred_server(@project.name, commits.join(','))
      else
        forward_to_deferred_server(@project.name, 'history')
      end
      respond_to do |format|
        format.json { @project.as_hash(request).to_json }
        format.html { flash[:notice] = 'project building history (refresh soon)' }
      end
    rescue RestClient::InternalServerError, RestClient::ResourceNotFound => error
      puts "error on #{project_path} error #{error}"
      flash[:error] = 'error creating project history, try again'
    end
    redirect "/#{@project.name}"
  else
    flash[:error] = 'churn project not found'
    redirect '/'
  end
end

get '/chart/*' do |project_path|
  project = Project.get_project(project_path)

  if project
    @chartdata = project.churn_chart_json
    erb :chart, :layout => false
  else
    flash[:error] = 'project to chart not found'
    redirect '/'
  end
end

##~ a = s.apis.add
##~ a.set :path => "/{project_name}", :produces => ["application/json"], :description => "Access to a churn project"
##
##~ op = a.operations.add
##~ op.type = "Project"
##~ op.set :method => "GET", :deprecated => false, :nickname => "get_project"
##~ op.summary = "Returns a single churn project by project_name"
##~ op.parameters.add :name => "project_name", :description => "The project_name of the churn project to be returned", :type => "string", :allowMultiple => false, :required => true, :paramType => "path"
##
## Declaring errors for the operation
##~ err = op.responseMessages.add
##~ err.set :message => "no project found", :code => 404
get '/*', :provides => [:html, :json] do |project_path|
  @project = Project.get_project(project_path)
  if @project
    respond_to do |format|
      format.json { @project.as_hash(request).to_json }
      format.html { erb :project }
    end
  else
    if project_path.strip.length > 0 && project_path!='favicon.ico'
      respond_to do |format|
        format.json { halt 404, json({ message: "no project found" }) }
        format.html { flash[:error] = "existing project not found, please add it" }
      end
    end
    redirect '/'
  end
end


##~ a = s.apis.add
##~ a.set :path => "/projects/add", :produces => ["application/json"], :description => "Create a new churn project resource"
##
##~ op = a.operations.add
##~ op.type = "string"
##~ op.set :method => "POST", :deprecated => false, :nickname => "create_project"
##~ op.summary = "creates a new churn project by project_name"
##~ op.parameters.add :name => "project_name", :description => "The project_name of the churn project to be created", :type => "string", :allowMultiple => false, :required => true, :paramType => "query"
##
post '/projects/add*', :provides => [:html, :json] do
  project_name = params && params['project_name']
  #fix starting with a slash if cleint passed with a slash
  project_name = project_name[1...project_name.length] if project_name[0]=='/'
  if project_name && project_name.length > 0
    begin
      project_data = Octokit.repo project_name
      if project_data
        gh_commits = Octokit.commits(project_name)
        if gh_commits.any?
          gh_commit = gh_commits.first
          commit = gh_commit['sha']
          commit_data = gh_commit
          find_or_create_project(project_name, project_data, commit, commit_data)
          flash[:notice] = "project #{project_name} created"
        else
          flash[:error] = "no commits found on github for #{project_name}"
        end
      else
        flash[:error] = "project #{project_name} couldn't be found on github"
      end
    rescue RestClient::InternalServerError, RestClient::ResourceNotFound => error
      error_msg = "error adding #{project_name} error #{error}"
      puts error_msg
      flash[:error] = error_msg
    rescue Octokit::NotFound
      flash[:notice] = "project not found try without full url or initial slash EX:'danmayer/churn'"
    end
  else
    flash[:notice] = 'project name required'
  end
  respond_to do |format|
    format.json { flash[:notice] || flash[:error] }
    format.html { redirect '/' }
  end
end

#handles github post push webhook calls
post '/' do
  if params['payload']
    receive_github_payload
  else
    receive_churn_client_payload
  end
end

private

def receive_github_payload
  puts "receiving github post commit hook payload"
  push = JSON.parse(params['payload'])
  project_url = push['repository']['url']
  project_name = project_url.gsub(/.*com\//,'')
  project_data = push['repository']
  commit = push['after']
  commit_data = push['commits'].detect{|a_commit| a_commit['id']==commit }
  find_or_create_project(project_name, project_data, commit, commit_data)
end

def receive_churn_client_payload
  puts "receiving churn client payload"
  results = JSON.parse(params['results'])
  if results
    project_name  = results['name']
    commit        = results['revision']
    churn_results = results['data']
    begin
      project_data = Octokit.repo project_name
    rescue Octokit::NotFound
      #non public project, ignore other project data besides the name
      project_data = {}
    end
    commit_data =
      begin
        gh_commit = Octokit.commits(project_name, nil, :sha => commit).first
      rescue Octokit::NotFound, Octokit::BadGateway
        #non public project, ignore other project data besides the name
        commit_data = {'sha' => commit,
        'timestamp' => Time.now,
        'message' => 'unknown: pushed via churn',
        'author' => 'unknown: pushed via churn'
      }
      end
    find_or_create_project(project_name, project_data, commit, commit_data, :rechurn => 'false')
    ChurnResult.new(project_name, commit).write_results(churn_results)
    puts "save churn results #{churn_results}"
    'OK'
  else
    msg = 'params for churn results must be wrapped in a results param'
    puts msg
    msg
  end
end

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
    if options[:rechurn]==nil || options[:rechurn]=='true'
      forward_to_deferred_server(project.name, commit)
      forward_to_deferred_server(project.name, 'history')
    end
  end
  project.clear_caches
end

def forward_to_deferred_server(project, commit, options = {})
  attempts = 0
  begin
    request_timeout = options.fetch(:timeout){ 6 }
    request_open_timeout    = options.fetch(:open_timeout){ 6 }
    resource = RestClient::Resource.new(DEFERRED_SERVER_ENDPOINT,
                                        :timeout => request_timeout,
                                        :open_timeout => request_open_timeout)

    resource.post(:signature => DEFERRED_SERVER_TOKEN,
                  :project => project,
                  :commit => commit,
                  :command => 'churn --yaml')
  rescue  RestClient::ResourceNotFound
    attempts +=1
    retry if attempts < 3
  rescue RestClient::RequestTimeout
    attempts +=1
    retry if attempts < 2
    puts "timed out during deferred-server hit"
  end
end
