module Hermes
  module Plugin
    class Cat
      ##
      # Helper module that makes it easier to write SAX parsers for Atom/RSS
      # feeds by providing some common attributes.
      #
      # @since 2012-06-27
      #
      module SAXHelper
        ##
        # The title of the latest entry.
        #
        # @since  2012-06-27
        # @return [String]
        #
        attr_reader :title

        ##
        # The URL of the latest entry.
        #
        # @since  2012-06-27
        # @return [String]
        #
        attr_reader :url

        ##
        # Instance of Time that contains the date of the newest entry.
        #
        # @since  2012-06-27
        # @return [Time]
        #
        attr_reader :date

        ##
        # Method that's called when processing text nodes.
        #
        # @since 2012-06-27
        # @param [String] text The text of the current node.
        #
        def characters(text)
          if @in_title and !@title
            @title = text
          end

          if @in_date and !@date
            @date = Time.parse(text)
          end
        end
      end # Helper
    end # Cat
  end # Plugin
end # Hermes
