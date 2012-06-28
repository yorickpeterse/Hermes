require 'json'
require 'zmq'
require 'uuid'

module Hermes
  module RPC
    ##
    # Class used for creating JSON RPC clients using 0MQ. Clients implement
    # version 2.0 of the JSON RPC protocol.
    #
    # @since 2012-06-28
    #
    class Client
      ##
      # The protocol version.
      #
      # @since  2012-06-28
      # @return [String]
      #
      VERSION = '2.0'

      ##
      # Hash containing all valid RPC methods/methods. The keys are stored as
      # strings to remove the need of having to convert these to symbols when
      # parsing messages.
      #
      # @since  2012-06-28
      # @return [Hash]
      #
      METHODS = {}

      ##
      # String containing the host to connect to.
      #
      # @since  2012-06-28
      # @return [String]
      #
      attr_reader :host

      ##
      # Creates a new instance of the client and connects to the host.
      #
      # @since 2012-06-28
      # @param [String] host The host and port to bind to.
      #
      def initialize(host)
        @host   = host
        context = ZMQ::Context.new(1)
        @socket = context.socket(ZMQ::REQ)

        @socket.connect(@host)
      end

      ##
      # Adds a new method that can be executed by the client.
      #
      # @example
      #  client = Hermes::RPC::Client.new('...')
      #
      #  client.add_method 'multiply' do |number|
      #    number * 2
      #  end
      #
      # @since 2012-06-28
      # @param [#to_s] name The name of the method.
      # @param [Proc] method The method to add.
      # @raise [ArgumentError] Raised if the specified method already exists.
      #
      def add_method(name, &method)
        name = name.to_s

        if METHODS.key?(name)
          raise(ArgumentError, "The method #{name} already exists")
        end

        METHODS[name] = method
      end

      ##
      # Executes a method on the server and waits for a reply.
      #
      # @since  2012-06-28
      # @param  [String|Symbol] method The name of the method to execute.
      # @param  [Array] args An array of arguments to pass to the method.
      # @return [Hash]
      #
      def call(method, *args)
        message = JSON.dump(
          :version => VERSION,
          :method  => method,
          :params  => args,
          :id      => UUID.generate
        )

        @socket.send(message)

        return JSON.load(@socket.recv)
      end

      ##
      # Stops the client.
      #
      # @since 2012-06-28
      #
      def stop
        @socket.close
      end
    end # Client
  end # RPC
end # Hermes
