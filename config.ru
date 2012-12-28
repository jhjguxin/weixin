require 'rubygems'
require 'bundler/setup'
require File.join(File.dirname(__FILE__),"server")

use Rack::ShowExceptions
use Rack::Runtime
use Rack::CommonLogger

run Sinatra::Application

