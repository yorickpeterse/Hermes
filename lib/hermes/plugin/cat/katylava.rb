module Hermes
  module Plugin
    class Cat
      ##
      # Feed parser for katylava's Picasa feed.
      #
      module Katylava
        ##
        # String containing the feed URL.
        #
        # @return [String]
        #
        URL = 'https://picasaweb.google.com/data/feed/base/user/' \
          '102318656152572319755/albumid/5629308986630915553'

        ##
        # Returns the details of the latest feed entry.
        #
        # @param [String] xml
        # @return [Array]
        #
        def self.parse(xml)
          document = Nokogiri::XML(xml)
          latest   = document.css('feed entry:first')

          return if latest.empty?

          title = latest.css('title').text
          url   = latest.css('content[src]').attr('src').to_s
          date  = Time.parse(latest.css('published').to_s)

          return url, title, date
        end
      end # Katylava
    end # Cat
  end # Plugin
end # Hermes
