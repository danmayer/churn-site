# encoding: UTF-8
require 'json'
require 'fileutils'
require 'rack-flash'
require 'redis'
require './lib/redis_initializer'
require './models/project'

set :public_folder, File.dirname(__FILE__) + '/public'
set :root, File.dirname(__FILE__)
enable :logging
enable :sessions
use Rack::Flash, :sweep => true

helpers do
end

before /.*/ do
  if request.host.match(/herokuapp.com/)
    redirect request.url.gsub("herokuapp.com",'picoappz.com').gsub(/churn-site\./,'curn.'), 301
  end
end

get '/' do
  @projects      = Project.projects
  flash[:notice] = "your up and running"
  erb :index
end

post '/' do
  push = JSON.parse(params['payload'])
  project_url = push['repository']['url']
  project_name = project_url.gsub(/.*com\//,'')
  Project.add_project(project_name)
end

private
