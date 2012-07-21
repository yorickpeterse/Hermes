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
      # Extracts the title of a URL. If the response page is a non HTML page
      # nil is returned instead of the title.
      #
      # @since  2012-07-06
      # @param  [String] url The URL for which to extract the title.
      # @return [String]
      #
      def url_title(url)
        response = Faraday.get(url)

        # Skip non HTML responses.
        if response.headers['content-type'] \
        and response.headers['content-type'] !~ %r{text/html}
          return
        end

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
      # @raise  [Faraday::Error::ClientError] Raised when the URL could not be
      #  shortened.
      #
      def shorten_url(url)
        response = Faraday.get(IS_GD_URL, :format => :simple, :url => url)

        if response.success? and !response.body.include?('error: please')
          return response.body.strip
        else
          raise(Faraday::Error::ClientError, response.body)
        end
      end
    end # URL
  end # Helper
end # Hermes
