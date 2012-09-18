Hermes.bot.configure do |c|
  c.nick     = 'hermes-bot'
  c.server   = 'irc.freenode.net'
  c.channels = ['']

  # Plugin configuration.
  c.plugins.prefix  = '.'
  c.plugins.plugins = Hermes::DEFAULT_PLUGINS

  # Wunderground API key for weather plugin
  c.plugins.options[Hermes::Plugin::Weather] = {:key => ''}
end

Hermes.bot.loggers.level = :info
