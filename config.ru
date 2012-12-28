require 'rubygems'
require 'bundler/setup'
require File.join(File.dirname(__FILE__),"server")

#logger = Logger.new("./log/#{Sinatra::Base.environment}.log")

#use Rack::CommonLogger, logger

set :raise_errors, true
set :views, File.dirname(__FILE__) + '/views'
set :public, File.dirname(__FILE__) + '/public'
set :app_file, __FILE__

log = File.new("./log/#{Sinatra::Base.environment}.log", "a")
STDOUT.reopen(log)
STDERR.reopen(log)
$stdout.sync=true
$stderr.sync=true


set :sessions, true
set :logging, true
set :dump_errors, false

run Sinatra::Application

