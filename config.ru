require File.expand_path('../app', __FILE__)
require File.expand_path('../lib/hermes', __FILE__)
require 'sinatra/base'
require 'hermes/controller/quotes'
require 'hermes/controller/words'

map '/quotes' do
  run Hermes::Controller::Quotes.new
end

map '/words' do
  run Hermes::Controller::Words.new
end
