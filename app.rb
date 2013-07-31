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

get '/' do
  @projects      = Project.projects
  flash[:notice] = "your up and running"
  erb :index
end

post '/' do
  push = JSON.parse(params['payload'])
  project_name = push['repository']['name']
  Projects.add_project(project_name)
end

private
