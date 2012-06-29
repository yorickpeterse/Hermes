module Hermes
  module Plugin
    ##
    # Allows users to perform a Google search. Users can search for text and
    # image results, in both cases on the first result is returned.
    #
    # @since 2012-06-30
    #
    class Google
      include Cinch::Plugin

      set :help => 'g/google - Returns the first Google result | ' \
        'gis - Returns the first result of Google images',
        :plugin_name => 'google'

      match /gis\s+(.+)/, :method => :image_search
      match /g\s+(.+)/, :method => :execute
      match /google\s(.+)/, :method => :execute

      ##
      # The Google API URL.
      #
      # @since  2012-06-30
      # @return [String]
      #
      URL = 'http://ajax.googleapis.com/ajax/services/search/%s?v=1.0&safe=off'

      ##
      # Returns the first result of Google.
      #
      # @since 2012-06-30
      # @param [Cinch::Message] message
      # @param [String] query The search query.
      #
      def execute(message, query)
        display_result(message, search('web', query))
      end

      ##
      # Returns the first result of Google images.
      #
      # @since 2012-06-30
      # @see   Hermes::Plugin::Google#execute
      #
      def image_search(message, query)
        display_result(message, search('images', query), false)
      end

      private

      ##
      # Displays a single search result.
      #
      # @since 2012-06-30
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
      # @since  2012-06-30
      # @param  [String] type The search type.
      # @param  [String] query The search query.
      # @return [Hash|FalseClass]
      #
      def search(type, query)
        begin
          response = HTTParty.get(URL % type, :query => {:q => query})
        rescue
          return false
        end

        if response.success?
          return JSON.load(response.body)['responseData']['results'][0]
        else
          return false
        end
      end
    end # Google
  end # Plugin
end # Hermes
