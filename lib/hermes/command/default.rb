module Hermes
  module Command
    ##
    # Default Shebang command that is used for starting the bot.
    #
    # @since 2012-06-28
    #
    class Default < Shebang::Command
      command :default

      banner 'Hermes is a multi process based IRC bot written in Ruby'
      usage  '$ hermes [COMMAND] [OPTIONS]'

      o :h, :help, 'Shows this help message', :method => :help

      #help 'Commands', "default  - Starts Hermes\n" \
      #  "  node     - Starts a DCell node"

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
