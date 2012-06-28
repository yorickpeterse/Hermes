require 'json'
require 'zmq'
require 'logger'

module Hermes
  module RPC
    ##
    # Class used for creating JSON RPC servers using 0MQ. The Server class
    # implements version 2.0 of the JSON RPC protocol.
    #
    # @since 2012-06-28
    #
    class Server
      ##
      # The protocol version.
      #
      # @since  2012-06-28
      # @return [String]
      #
      VERSION = '2.0'

      ##
      # Hash containing the various JSON RPC error codes.
      #
      # @since  2012-06-28
      # @return [Hash]
      #
      ERRORS = {
        :invalid_json    => -32700,
        :invalid_request => -32600,
        :invalid_method  => -32601,
        :invalid_params  => -32602,
        :internal        => -32603
      }

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
      # String containing the host the server will be bound to.
      #
      # @since  2012-06-28
      # @return [String]
      #
      attr_accessor :host

      ##
      # The amount of seconds to wait after a single iteration of the event
      # loop.
      #
      # @since  2012-06-28
      # @return [Fixnum]
      #
      attr_accessor :wait

      ##
      # The logger to use.
      #
      # @since  2012-06-28
      # @return [Logger]
      #
      attr_accessor :logger

      ##
      # Creates a new instance of the server.
      #
      # @since 2012-06-28
      # @param [String] host The host and port to bind to.
      # @param [Fixnum] wait The amount of seconds to wait after a single
      #  iteration of the event loop.
      #
      def initialize(host, wait = 0.1, logger = Logger.new(STDOUT))
        @host   = host
        @wait   = wait
        @logger = logger
      end

      ##
      # Adds a new method that can be executed by the server.
      #
      # @example
      #  server = Hermes::RPC::Server.new('...')
      #
      #  server.add_method 'multiply' do |number|
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
      # Starts the RPC server and processes incoming RPC messages.
      #
      # @since 2012-06-28
      #
      def start
        @logger.info("Starting server at #{@host}")

        context = ZMQ::Context.new(1)
        @socket = context.socket(ZMQ::REP)

        @socket.bind(@host)

        begin
          loop do
            message = @socket.recv(ZMQ::NOBLOCK)

            if message
              request = parse_message(message)

              if request
                if request['id']
                  info = 'Call "%s" by message %s' \
                    % [request['method'], request['id']]
                else
                  info = 'Call "%s" by an unknown message' % request['method']
                end

                @logger.info(info)

                params = request['params'] || []
                result = METHODS[request['method']].call(*params)

                reply(request['id'], result)
              end
            end

            sleep(@wait)
          end
        rescue Interrupt
          @logger.info('Shutting down')

          stop
          exit
        end
      end

      ##
      # Parses a JSON RPC message and returns a Hash. If the message was
      # invalid `false` is returned instead.
      #
      # @since  2012-06-28
      # @param  [String] message The message to parse.
      # @return [Hash|FalseClass]
      #
      def parse_message(message)
        begin
          parsed = JSON.load(message)
        rescue e
          error(nil, ERRORS[:invalid_json], e.message)

          return false
        end

        # An ID can be set to nil but is always required regardless of the
        # value.
        if !parsed.key?('id')
          error(
            nil,
            ERRORS[:invalid_request],
            'No ID was specified'
          )

          return false
        end

        # Check if a method was specified.
        if !parsed.key?('method')
          error(
            parsed[:id],
            ERRORS[:invalid_request],
            'No method was specified'
          )

          return false
        end

        # Check if the specified method exists.
        unless METHODS.key?(parsed['method'])
          error(
            parsed['id'],
            ERRORS[:invalid_method],
            'The specified method does not exist'
          )

          return false
        end

        # Check if the parameters are valid.
        if parsed.key?('params') \
        and !(parsed['params'].is_a?(Array) || parsed['params'].is_a?(Hash))
          error(
            parsed['id'],
            ERRORS[:invalid_params],
            'The params key did not contain a valid object or array'
          )

          return false
        end

        # Check if the amount of parameters specified matches the required
        # amount of the method.
        required  = METHODS[parsed['method']].arity
        specified = (parsed['params'] || []).length

        if required != specified
          error(
            parsed['id'],
            ERRORS[:invalid_params],
            "Incorrect parameter amount, expected " \
              "#{required} bot got #{specified} instead"
          )

          return false
        end

        return parsed
      end

      ##
      # Sends an RPC reply.
      #
      # @since 2012-06-28
      # @param [String] id The ID of the original message.
      # @param [Mixed]  result The result data to send with the reply.
      #
      def reply(id, result)
        json = JSON.dump(:jsonrpc => VERSION, :result => result, :id => id)

        @socket.send(json)
      end

      ##
      # Sends an RPC error to the client.
      #
      # @since 2012-06-28
      # @param [String] id The ID of the original message.
      # @param [Fixnum] code The error code to send.
      # @param [String] message The error message.
      #
      def error(id, code, message)
        if id
          error = 'Invalid request by message %s: %s, %s' % [id, code, message]
        else
          error = 'Invalid requiest by an unknown message: %s, %s' \
            % [code, message]
        end

        @logger.error(error)

        json = JSON.dump(
          :jsonrpc => VERSION,
          :error   => {:code => code, :message => message},
          :id      => id
        )

        @socket.send(json)
      end

      ##
      # Stops the RPC server.
      #
      # @since 2012-06-28
      #
      def stop
        @socket.close
      end
    end # Server
  end # RPC
end # Hermes
