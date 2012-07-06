module Hermes
  module Controller
    ##
    # Sinatra controller that displays a list of all the available endpoints.
    #
    # @since 2012-07-06
    #
    class Endpoints < Sinatra::Base
      ##
      # Displays the endpoints.
      #
      # @since 2012-07-06
      #
      get '/' do
        content_type 'application/json'

        return JSON.dump(
          '/'       => 'Displays a list of all the available endpoints',
          '/quotes' => 'Read only access to the list of quotes',
          '/words'  => 'Read only access to the list of words'
        )
      end
    end # Endpoints
  end # Controller
end # Hermes
