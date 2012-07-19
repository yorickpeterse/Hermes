Hermes.bot.configure do |c|
  c.nick     = 'hermes-bot'
  c.server   = 'irc.freenode.net'
  c.channels = ['']

  # Plugin configuration.
  c.plugins.prefix  = '.'
  c.plugins.plugins = Hermes::DEFAULT_PLUGINS
end

Hermes.bot.loggers.level = :info

# Connect to the database.
Hermes.database = Sequel.connect(
  :adapter  => 'sqlite',
  :database => File.expand_path('../../database.db', __FILE__),
  :encoding => 'utf8',
  :test     => true
)
