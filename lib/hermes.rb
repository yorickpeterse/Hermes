require 'bundler/setup'
require 'nokogiri'
require 'httparty'
require 'cinch'
require 'json'
require 'sequel'
require 'sanitize'
require 'uri'
require 'twitter'

$:.unshift(File.expand_path('../', __FILE__))

# Load all the helpers and plugins.
['helper', 'plugin'].each do |directory|
  Dir[File.expand_path("../hermes/#{directory}/*.rb", __FILE__)].each do |file|
    require file
  end
end

Sequel.extension(:migration)
Sequel::Model.plugin(:validation_helpers)

##
# Hermes is an IRC bot written to replace the "forrstdotcom" bot in the
# `#forrst-chat` IRC channel.
#
# @since 2012-06-27
#
module Hermes
  ##
  # Array containing the signals that will shut down the bot gracefully.
  #
  # @since  2012-06-27
  # @return [Array]
  #
  SIGNALS = ['INT', 'QUIT']

  ##
  # The date format to use whe ndisplaying dates with times.
  #
  # @since  2012-07-06
  # @return [String]
  #
  DATE_TIME_FORMAT = '%Y-%m-%d %H:%M'

  ##
  # Array containing the plugins that should be enabled by default.
  #
  # @since  2012-06-30
  # @return [Array]
  #
  DEFAULT_PLUGINS = [
    Hermes::Plugin::Cat,
    Hermes::Plugin::Down,
    Hermes::Plugin::UrbanDictionary,
    Hermes::Plugin::Google,
    Hermes::Plugin::Help,
    Hermes::Plugin::Remember,
    Hermes::Plugin::Quote,
    Hermes::Plugin::Tell,
    Hermes::Plugin::URL,
    Hermes::Plugin::Weather,
    Hermes::Plugin::Twitter
  ]

  class << self
    ##
    # The database connection to use.
    #
    # @since 2012-06-30
    #
    attr_reader :database

    ##
    # Sets the database connection and loads all the models.
    #
    # @since 2012-07-05
    # @param [Mixed] db The database connection to use.
    #
    def database=(db)
      @database = db

      Dir[File.expand_path('../hermes/model/*.rb', __FILE__)].each do |model|
        require model
      end
    end

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
