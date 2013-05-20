module Hermes
  module Plugin
    ##
    # Plugin that allows users to retrieve definitions from Urban Dictionary.
    #
    class UrbanDictionary
      include Cinch::Plugin

      set :help => 'u/ud/urban [TERM] - Retrieves the definition of a term ' \
        'using Urban Dictionary',
        :plugin_name => 'urban'

      match(/(u|ud|urban)\s+(.+)/, :method => :execute)

      ##
      # The URL to send HTTP requests to.
      #
      # @return [String]
      #
      URL = 'http://api.urbandictionary.com/v0/define'

      ##
      # Executes the plugin.
      #
      # @param [Cinch::Message] message
      # @param [String] command The command that was used to query UD.
      # @param [String] term The term to look for.
      #
      def execute(message, command, term)
        begin
          response = HTTP.get(URL, :query => {:term => term})
        rescue e
          message.reply("Failed to get the definition: #{e.message}", true)

          return
        end

        if response.ok?
          json = JSON.load(response.body)

          if json['list'][0]
            item       = json['list'][0]
            definition = item['definition']
            example    = item['example']

            if definition.length > 100
              definition = definition[0..97] + '...'
            end

            if example.length > 100
              example = example[0..97] + '...'
            end

            definition = definition.gsub(/\r\n|\n/, ' ').strip
            example    = example.gsub(/\r\n|\n/, ' ').strip

            message.reply(
              '%s | Example: %s | Link: %s' % [
                definition,
                example,
                item['permalink']
              ],
              true
            )
          else
            message.reply('No definition was found', true)
          end
        else
          message.reply(
            "Failed to retrieve the definition: " \
              "#{response.status} #{response.body}",
            true
          )
        end
      end
    end # UrbanDictionary
  end # Plugin
end # Hermes
