module Hermes
  module Plugin
    ##
    # Plugin that allows users to retrieve definitions from Urban Dictionary.
    #
    # @since 2012-06-30
    #
    class UrbanDictionary
      include Cinch::Plugin

      set :help => 'u/urban [TERM] - Retrieves the definition of a term ' \
        'using Urban Dictionary',
        :plugin_name => 'urban'

      match /u\s+(\S+)/,     :method => :execute
      match /urban\s+(\S+)/, :method => :execute

      ##
      # The URL to send HTTP requests to.
      #
      # @since  2012-06-30
      # @return [String]
      #
      URL = 'http://api.urbandictionary.com/v0/define'

      ##
      # Executes the plugin.
      #
      # @since 2012-06-30
      # @param [Cinch::Message] message
      # @param [String] term The term to look for.
      #
      def execute(message, term)
        begin
          response = HTTP.get(URL, :term => term)
        rescue e
          message.reply("Failed to get the definition: #{e.message}", true)

          return
        end

        if response.success?
          json = JSON.load(response.body)

          if json['list'][0]
            item = json['list'][0]

            message.reply(
              "#{item['definition']} | Example: #{item['example']}",
              true
            )
          else
            message.reply('No definition was found', true)
          end
        else
          message.reply(
            "Failed to retrieve the definition: " \
              "#{response.status} #{response.message}",
            true
          )
        end
      end
    end # UrbanDictionary
  end # Plugin
end # Hermes
