require File.expand_path('../submodules/deployment/lib/deployment', __FILE__)

application = Deployment::Application.new do |app|
  app.name        = 'hermes'
  app.description = 'IRC bot for #forrst-chat on Freenode'
  app.directory   = '/home/hermes/hermes'
  app.after       = ['postgresql.service']
  app.command     = 'ruby bin/hermes'
end

application.start!
