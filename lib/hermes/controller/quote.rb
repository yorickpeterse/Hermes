module Hermes
  module Controller
    ##
    # Sinatra controller that provides read-only access to the quotes stored in
    # the bot's database.
    #
    # @since 2012-07-06
    #
    class Quote < Sinatra::Base
      ##
      # Displays a list of all the quotes. The following parameters can be set:
      #
      # * limit: the maximum amount of quotes to retrieve, set to 100 by
      #   default.
      # * offset: the row offset to use when limiting the dataset.
      # * channel: the channel for which to retrieve the quotes.
      # * nick: the nick of the user for which to retrieve the quotes.
      #
      # @since 2012-07-06
      #
      get '/' do
        content_type 'application/json'

        limit  = params[:limit]  || 100
        offset = params[:offset] || 0
        quotes = Model::Quote.limit(limit, offset)

        if params[:channel]
          quotes = quotes.filter(:channel => params[:channel])
        end

        if params[:nick]
          quotes = quotes.filter(:nick => params[:nick])
        end

        return JSON.dump(quotes.map { |q| q.values })
      end

      ##
      # Retrieves a single quote. If the quote does not exist a message is
      # displayed about this and the HTTP status is set to 404.
      #
      # @since 2012-07-06
      #
      get '/:id' do
        content_type 'application/json'

        quote = Model::Quote[params[:id]]

        if quote
          return JSON.dump(quote.values)
        else
          status 404

          return JSON.dump(:message => 'The quote does not exist')
        end
      end
    end # Controller
  end # API
end # Hermes
