require File.expand_path('../app', __FILE__)
require File.expand_path('../lib/hermes', __FILE__)
require 'sinatra/base'
require 'hermes/controller/quote'

map '/quotes' do
  run Hermes::Controller::Quote.new
end
