require File.expand_path('../lib/hermes', __FILE__)

['config'].each do |config|
  require File.expand_path("../config/#{config}.rb", __FILE__)
end
