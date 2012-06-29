module Hermes
  module Command
    ##
    # Default Shebang command that is used for starting the bot.
    #
    # @since 2012-06-28
    #
    class Default < Shebang::Command
      command :default

      banner 'Hermes is a simple IRC bot written using Cinch'
      usage  '$ hermes [COMMAND] [OPTIONS]'

      o :h, :help, 'Shows this help message', :method => :help

      ##
      # Runs the command.
      #
      # @since 2012-06-28
      #
      def index
        Hermes.start
      end
    end # Node
  end # Command
end # Hermes
