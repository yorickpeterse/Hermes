module Hermes
  module Plugin
    class Cat
      ##
      # Feed parser for http://cat.yorickpeterse.com/.
      #
      module Yorickpeterse
        ##
        # String containing the feed URL.
        #
        # @return [String]
        #
        URL = 'http://cat.yorickpeterse.com/catom_feed.atom'

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

          url   = latest.css('link').attr('href').to_s
          title = latest.css('title').text
          date  = Time.parse(latest.css('updated').text)

          return url, title, date
        end
      end # Yorickpeterse
    end # Cat
  end # Plugin
end # Hermes
