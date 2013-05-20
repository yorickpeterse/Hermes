require 'cgi'
require 'json'
require 'uri'
require 'cinch'
require 'faraday'
require 'faraday_middleware'
require 'nokogiri'
require 'sanitize'
require 'sequel'
require 'twitter'
require 'youtube_it'
require 'wunderground'

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
#
module Hermes
  ##
  # Array containing the signals that will shut down the bot gracefully.
  #
  # @return [Array]
  #
  SIGNALS = ['INT', 'QUIT']

  ##
  # The date format to use whe ndisplaying dates with times.
  #
  # @return [String]
  #
  DATE_TIME_FORMAT = '%Y-%m-%d %H:%M'

  ##
  # Array containing the plugins that should be enabled by default.
  #
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
    Hermes::Plugin::Twitter,
    Hermes::Plugin::Wikipedia,
    Hermes::Plugin::Youtube
  ]

  ##
  # Hash containing request configuration options for Faraday.
  #
  # @return [Hash]
  #
  REQUEST_OPTIONS = {:timeout => 15}

  ##
  # Hash containing configuration options for SSL.
  #
  # @return [Hash]
  #
  SSL_OPTIONS = {:verify_mode => OpenSSL::SSL::VERIFY_NONE}

  ##
  # The Faraday connection to use.
  #
  # @return [Faraday::Connection]
  #
  HTTP = Faraday.new(:request => REQUEST_OPTIONS, :ssl => SSL_OPTIONS) do |f|
    f.response :follow_redirects
    f.adapter  Faraday.default_adapter
  end

  class << self
    ##
    # The database connection to use.
    #
    #
    attr_reader :database

    ##
    # Sets the database connection and loads all the models.
    #
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
    #
    def stop
      @bot.quit
    end
  end # class << self
end # Hermes
