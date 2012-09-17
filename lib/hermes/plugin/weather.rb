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
      # Retrieves the weather for the specified location. If no location is
      # given the last used location for the user is used (if any).
      #
      # @since 2012-07-08
      # @param [Cinch::Message] message
      # @param [String] location The location for which to retrieve the weather
      #  forecast.
      #
      def execute(message, location)
        if config[:key].nil? or config[:key].empty?
          message.reply("No API key set")
          return
        end

        @wunder ||= Wunderground.new(config[:key])

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

        begin
          resp = @wunder.conditions_for(location)['current_observation']

          city      = "#{resp['display_location']['city']}/#{resp['display_location']['country_iso3166']}"
          condition = resp['weather']
          temp_f    = resp['temp_f']
          temp_c    = resp['temp_c']
          humidity  = resp['relative_humidity']
          wind      = resp['wind_string']

          reply = '%s: %s, %sF/%sC %s, %s' % \
                  [city, condition, temp_f, temp_c, humidity, wind]
        rescue
          reply = "Unable to complete lookup"
        end

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
