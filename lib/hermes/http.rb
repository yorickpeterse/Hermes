module Hermes
  ##
  # {Hermes::HTTP} acts as a small wrapper around HTTPClient to make it easier
  # to deal with common response formats such as JSON.
  #
  class HTTP
    ##
    # The amount of seconds after which to time out an HTTP connection.
    #
    # @return [Numeric]
    #
    TIMEOUT = 15

    def initialize
      @client = HTTPClient.new

      @client.send_timeout    = TIMEOUT
      @client.connect_timeout = TIMEOUT
      @client.receive_timeout = TIMEOUT
    end

    ##
    # GET a resource and automatically follow redirects.
    #
    # @see HTTPClient#get
    #
    def get(url, args = {})
      args[:follow_redirect] ||= true

      return @client.get(url, args)
    end

    ##
    # @see HTTPClient#post
    #
    def post(*args)
      return @client.post(*args)
    end

    ##
    # @see HTTPClient#head
    #
    def head(*args)
      return @client.head(*args)
    end

    ##
    # Requests a URL and decodes the JSON response. The return value is the raw
    # response object and the JSON decoded body.
    #
    # @see #get
    # @return [Array]
    #
    def get_json(*args)
      response = get(*args)

      return response, JSON(response.body)
    end
  end # HTTP
end # Hermes
