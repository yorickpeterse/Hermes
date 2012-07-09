module Hermes
  module Plugin
    ##
    # Plugin for search Wikipedia.
    #
    # @since 2012-07-08
    #
    class Wikipedia
      include Cinch::Plugin

      match /w\s+(.+)/,    :method => :execute
      match /wiki\s+(.+)/, :method => :execute

      ##
      # The URL of Wikipedia's search system.
      #
      # @since  2012-07-08
      # @return [String]
      #
      URL = 'http://en.wikipedia.org/w/api.php'

      # ?action=opensearch&format=xml

      ##
      # Searches Wikipedia for the given query.
      #
      # @since 2012-07-08
      # @param [Cinch::Message] message
      # @param [String] query The search query.
      #
      def execute(message, query)
        response = Faraday.get(
          URL,
          :format => 'xml',
          :action => 'opensearch',
          :search => query,
          :limit  => 1
        )

        if !response.success?
          message.reply(
            "Failed to query Wikipedia: #{response.status} " \
              "#{response.message}",
            true
          )

          return
        end

        document = Nokogiri::XML(response.body)
        item     = document.css('Section Item')

        if !item or item.length <= 0
          message.reply('No results were found', true)

          return
        end

        desc = item.css('Description').text.strip
        url  = item.css('Url').text.strip

        message.reply("#{desc} -- #{url}", true)
      end
    end # Wikipedia
  end # Plugins
end # Hermes
