module Hermes
  module Plugin
    ##
    # Plugin that retrieves the weather forecast for a given location.
    #
    # @since 2012-07-08
    #
    class Weather
      include Cinch::Plugin

      match /weather\s*(.*)/

      set :help => 'weather [LOCATION] - Retrieves the weather forecast',
        :plugin_name => 'weather'

      ##
      # The base URL of the Google weather API.
      #
      # @since  2012-07-08
      # @return [String]
      #
      API_URL = 'http://www.google.com/ig/api'

      ##
      # Retrieves the weather for the specified location. If no location is
      # given the last used location for the user is used (if any).
      #
      # @since 2012-07-08
      # @param [Cinch::Message] message
      # @param [String] location The location for which to retrieve the weather
      #  forecast.
      #
      def execute(message, location)
        nick              = message.user.nick
        channel           = message.channel.to_s
        existing_location = Model::WeatherLocation[
          :nick    => nick,
          :channel => channel
        ]

        # Check if the bot has a location stored for the user.
        if !location or location.empty?
          if existing_location
            location = existing_location.location
          else
            message.reply('No location was specified', true)

            return
          end
        end

        response = HTTP.get(API_URL, :weather => location)

        if !response.success?
          message.reply(
            "Failed to retrieve the weather forecast, HTTP status: " \
              "#{response.status}",
            true
          )

          return
        end

        document = Nokogiri::XML(response.body)

        if document.css('weather problem_cause').length > 0
          message.reply('Failed to retrieve the weather forecast', true)

          return
        end

        city = document.css('weather forecast_information city').attr('data')

        current   = document.css('weather current_conditions')
        condition = current.css('condition').attr('data')
        temp_f    = current.css('temp_f').attr('data')
        temp_c    = current.css('temp_c').attr('data')
        humidity  = current.css('humidity').attr('data')
        wind      = current.css('wind_condition').attr('data')
        forecast  = document.css('weather forecast_conditions')[0]
        high      = forecast.css('high').attr('data')
        low       = forecast.css('low').attr('data')

        reply = '%s: %s, %sF/%sC (H:%s, L:%s), %s, %s' % \
          [city, condition, temp_f, temp_c, high, low, humidity, wind]

        if existing_location
          existing_location.update(:location => location)
        else
          Model::WeatherLocation.create(
            :nick     => nick,
            :channel  => channel,
            :location => location
          )
        end

        message.reply(reply, true)
      end
    end # Weather
  end # Plugin
end # Hermes
