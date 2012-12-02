module Hermes
  module Plugin
    class Cat
      ##
      # Feed parser for jwa's Picasa feed.
      #
      # @since 2012-12-02
      #
      module Jwa
        ##
        # The SAX parser to use for parsing jwa's feed.
        #
        # @since 2012-12-02
        #
        class Parser < Nokogiri::XML::SAX::Document
          include SAXHelper

          ##
          # Called whenever a new element's opening tag was found. If the tag
          # is an "entry" tag the parser will be notified to extract the next
          # title and URL and then stop parsing the document.
          #
          # @since 2012-12-02
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

            if @in_entry and name == 'media:content' and !@url
              url = attrs.assoc('url')

              if url and url[1]
                @url = url[1]
              end
            end
          end
        end # Parser

        ##
        # String containing the feed URL.
        #
        # @since  2012-12-02
        # @return [String]
        #
        URL = 'https://picasaweb.google.com/data/feed/base/user/' \
          '111565248509530611766/albumid/5700454322303846897?alt=rss&kind=photo&authkey=Gv1sRgCIXF2pzIgqC7zAE'

        ##
        # Returns the details of the latest feed entry.
        #
        # @since  2012-12-02
        # @return [Array]
        #
        def self.parse(xml)
          sax_parser = Parser.new
          parser     = Nokogiri::XML::SAX::Parser.new(sax_parser)

          parser.parse(xml)

          return sax_parser.url, sax_parser.title, sax_parser.date
        end
      end # Katylava
    end # Cat
  end # Plugin
end # Hermes
