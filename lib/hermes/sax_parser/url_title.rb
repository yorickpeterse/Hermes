module Hermes
  module SAXParser
    ##
    # SAX parser for extracting the title of a webpage.
    #
    #
    class URLTitle < Nokogiri::XML::SAX::Document
      ##
      # The title of the current document.
      #
      # @return [String]
      #
      attr_reader :title

      ##
      # Called whenever a new element was found.
      #
      # @param [String] name The name of the element.
      # @param [Array] attrs An array of attributes.
      #
      def start_element(name, attrs)
        @in_title = true if name == 'title'
      end

      ##
      # Called when processing a text node.
      #
      # @param [String] text The text of the current node.
      #
      def characters(text)
        if @in_title and !@title
          @title = text
        end
      end
    end # URLTitle
  end # SAXParser
end # Hermes
