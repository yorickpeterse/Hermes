require 'hermes/sax_parser/url_title'

module Hermes
  module Helper
    ##
    # Helper module for working with URLs. This helper makes it easy to extract
    # URL titles, shorten URLs and perform other operations using URLs.
    #
    # @since 2012-07-06
    #
    module URL
      ##
      # The URL of the is.gd API.
      #
      # @since  2012-07-06
      # @return [String]
      #
      IS_GD_URL = 'http://is.gd/create.php'

      ##
      # Extracts the title of a URL.
      #
      # @since  2012-07-06
      # @param  [String] url The URL for which to extract the title.
      # @return [String]
      #
      def url_title(url)
        response   = HTTParty.get(url)
        head       = response.body.split(/<body/)[0]
        url_parser = Hermes::SAXParser::URLTitle.new
        parser     = Nokogiri::HTML::SAX::Parser.new(url_parser)

        parser.parse(head)

        return url_parser.title.strip
      end

      ##
      # Shortens a URL and returns the short version.
      #
      # @since  2012-07-06
      # @param  [String] url The URL to shorten.
      # @return [String]
      # @raise  [HTTParty::ResponseError] Raised when the URL could not be
      #  shortened.
      #
      def shorten_url(url)
        response = HTTParty.get(
          IS_GD_URL,
          :query => {:format => :simple, :url => url}
        )

        if response.success? and !response.body.include?('error: please')
          return response.body.strip
        else
          raise(HTTParty::ResponseError, response.body)
        end
      end
    end # URL
  end # Helper
end # Hermes
