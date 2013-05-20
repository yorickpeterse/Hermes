module Hermes
  module Plugin
    ##
    # Allows users to perform a Google search. Users can search for text and
    # image results, in both cases on the first result is returned.
    #
    class Google
      include Cinch::Plugin

      set :help => 'g/google [QUERY] - Returns the first Google result | ' \
        'gis [QUERY] - Returns the first result of Google images',
        :plugin_name => 'google'

      match(/gis\s+(.+)/, :method => :image_search)
      match(/g\s+(.+)/, :method => :execute)
      match(/google\s(.+)/, :method => :execute)

      ##
      # The Google API URL.
      #
      # @return [String]
      #
      URL = 'http://ajax.googleapis.com/ajax/services/search/%s?v=1.0&safe=off'

      ##
      # Returns the first result of Google.
      #
      # @param [Cinch::Message] message
      # @param [String] query The search query.
      #
      def execute(message, query)
        display_result(message, search('web', query))
      end

      ##
      # Returns the first result of Google images.
      #
      # @see   Hermes::Plugin::Google#execute
      #
      def image_search(message, query)
        display_result(message, search('images', query), false)
      end

      private

      ##
      # Displays a single search result.
      #
      # @param [Cinch::Message] message
      # @param [Hash] result
      # @param [TrueClass|FalseClass] include_content
      #
      def display_result(message, result, include_content = true)
        if result and result.key?('content')
          title = Sanitize.clean(result['titleNoFormatting']).squeeze(' ')

          if include_content
            content        = Sanitize.clean(result['content']).squeeze(' ')
            message_string = %Q{#{result['url']} - #{title} - "#{content}"}
          else
            message_string = %Q{#{result['url']} - #{title}}
          end

          message.reply(message_string, true)
        else
          message.reply('No results were found for the specified query', true)
        end
      end

      ##
      # Queries Google and returns the first result.
      #
      # @param  [String] type The search type.
      # @param  [String] query The search query.
      # @return [Hash|FalseClass]
      #
      def search(type, query)
        begin
          response, json = Hermes.http.get_json(
            URL % type,
            :query => {:q => query}
          )
        rescue
          return false
        end

        if response.ok?
          return json['responseData']['results'][0]
        else
          return false
        end
      end
    end # Google
  end # Plugin
end # Hermes
