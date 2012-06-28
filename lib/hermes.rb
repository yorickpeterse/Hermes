require 'nokogiri'
require 'httparty'
require 'cinch'

$:.unshift(File.expand_path('../', __FILE__))

require 'hermes/rpc/server'
require 'hermes/plugin/cat'
require 'hermes/plugin/down'

##
# Hermes is an IRC bot written to replace the "forrstdotcom" bot in the
# `#forrst-chat` IRC channel.
#
# @since 2012-06-27
#
module Hermes
  class << self
    ##
    # Array containing the signals that will shut down the bot gracefully.
    #
    # @since  2012-06-27
    # @return [Array]
    #
    SIGNALS = ['INT', 'QUIT']

    ##
    # Instance of {Hermes::RPC::Server} that listens for commands and relays
    # data to the IRC server.
    #
    # @since  2012-06-28
    # @return [Hermes::RPC::Server]
    #
    attr_reader :rpc_server

    ##
    # Attribute that contains the primary instance of `Cinch::Bot`.
    #
    # @since  2012-06-27
    # @return [Cinch::Both]
    #
    def bot
      @bot = Cinch::Bot.new if @bot.nil?

      return @bot
    end

    ##
    # Starts the bot and connects to the IRC server specified in the
    # Cinch configuration.
    #
    # @since 2012-06-27
    #
    def start
      @rpc_server = Hermes::RPC::Server.new('tcp://*:9000')

      begin
        rpc_thread = Thread.new { @rpc_server.start }
        bot_thread = Thread.new { @bot.start }

        rpc_thread.join
        bot_thread.join
      rescue Interrupt
        stop
      end

      SIGNALS.each do |sig|
        trap(sig) { stop }
      end
    end

    ##
    # Disconnects from the IRC server and shuts the bot down.
    #
    # @since 2012-06-27
    #
    def stop
      @bot.quit
      @rpc_server.stop
    end
  end # class << self
end # Hermes
