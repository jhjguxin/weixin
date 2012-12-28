require 'rubygems'
require 'bundler/setup'
require File.join(File.dirname(__FILE__),"server")

#logger = Logger.new("./log/#{Sinatra::Base.environment}.log")

#use Rack::CommonLogger, logger

set :raise_errors, true


class Server
  configure :production do
    set :haml, { :ugly=>true }
    set :clean_trace, true
    Dir.mkdir('log') unless File.exist?('log')

    $logger = Logger.new("./log/#{Sinatra::Base.environment}.log",'weekly')
    $logger.level = Logger::WARN

    # Spit stdout and stderr to a file during production
    # in case something goes wrong
    $stdout.reopen("./log/#{Sinatra::Base.environment}_stdout.log", "w")
    $stdout.sync = true
    $stderr.reopen($stdout)
  end

  configure :development do
    $logger = Logger.new(STDOUT)
  end
end

set :sessions, true
set :logging, true
set :dump_errors, false

run Server

