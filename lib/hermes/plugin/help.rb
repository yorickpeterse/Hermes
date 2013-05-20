module Hermes
  module Plugin
    ##
    # Plugin that retrieves all the available plugin names and displays them to
    # the user.
    #
    class Help
      include Cinch::Plugin

      set :help => 'help [COMMAND] - Shows the help message of a plugin ' \
        'or lists all available commands',
        :plugin_name => 'help'

      match(/help$/)

      ##
      # Executes the plugin.
      #
      # @param [Cinch::Message] message
      #
      def execute(message)
        names = Hermes.bot.plugins.map do |plugin|
          plugin.class.instance_variable_get(:@plugin_name)
        end

        message.reply("Available commands: #{names.sort.join(', ')}")
      end
    end # Help
  end # Plugin
end # Hermes
