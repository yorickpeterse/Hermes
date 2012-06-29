require 'nokogiri'
require 'httparty'
require 'cinch'

$:.unshift(File.expand_path('../', __FILE__))

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
      SIGNALS.each do |sig|
        trap(sig) { stop }
      end

      @bot.start
    end

    ##
    # Disconnects from the IRC server and shuts the bot down.
    #
    # @since 2012-06-27
    #
    def stop
      @bot.quit
    end
  end # class << self
end # Hermes
