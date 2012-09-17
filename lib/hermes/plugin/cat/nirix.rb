module Hermes
  module Plugin
    class Cat
      ##
      # Feed parser for http://cat.jackpolgar.com.
      #
      # @since 2012-09-18
      #
      module Nirix
        ##
        # The SAX parser to use for parsing the feed.
        #
        # @since 2012-09-18
        #
        class Parser < Nokogiri::XML::SAX::Document
          include SAXHelper

          ##
          # Called whenever a new element's opening tag was found. If the tag
          # is an "entry" tag the parser will be notified to extract the next
          # title and URL and then stop parsing the document.
          #
          # @since 2012-09-18
          # @param [String] name The name of the current element.
          # @param [Array] attrs An array of attributes.
          #
          def start_element(name, attrs)
            if name == 'entry' and !@in_entry
              @in_entry = true
            end

            # Get the text of the <title> tag.
            if @in_entry and name == 'title' and !@title
              @in_title = true
            end

            # Get the date
            if @in_entry and name == 'updated' and !@date
              @in_date = true
            end

            # Get the URL
            if @in_entry and name == 'link' and !@url
              rel  = attrs.assoc('rel')
              href = attrs.assoc('href')

              if rel and rel[1] == 'alternate' and href and href[1]
                @url = href[1]
              end
            end
          end
        end # Parser

        ##
        # String containing the feed URL.
        #
        # @since  2012-09-18
        # @return [String]
        #
        URL = 'http://cat.jackpolgar.com/feed.atom'

        ##
        # Returns the details of the latest feed entry.
        #
        # @since  2012-09-18
        # @return [Array]
        #
        def self.parse(xml)
          sax_parser = Parser.new
          parser     = Nokogiri::XML::SAX::Parser.new(sax_parser)

          parser.parse(xml)

          return sax_parser.url, sax_parser.title, sax_parser.date
        end
      end # Nirix
    end # Cat
  end # Plugin
end # Hermes
