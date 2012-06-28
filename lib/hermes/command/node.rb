module Hermes
  module Command
    ##
    # Shebang command used for starting DCell nodes.
    #
    # @since 2012-06-28
    #
    class Node < Shebang::Command
      command :node

      banner 'Starts a single worker node and optionally connects to a cluster'
      usage  '$ hermes node ID ADDRESS [OPTIONS]'

      o :h, :help, 'Shows this help message', :method => :help
      #o :i, :id, 'The ID of the node to connect to', :type => String
      #o :a, :address, 'The address of the node to connect to', :type => String

      ##
      # Runs the command.
      #
      # @since 2012-06-28
      # @param [Array] args Array of command line arguments.
      #
      def index(args = [])
        help if args.length != 2

      end
    end # Node
  end # Command
end # Hermes
