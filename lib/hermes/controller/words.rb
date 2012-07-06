module Hermes
  module Controller
    ##
    # Sinatra controller that provides read only access to the list of words
    # stored in the bot.
    #
    # @since 2012-07-06
    #
    class Words < Sinatra::Base
      ##
      # Displays a list of all the words that have been stored.
      #
      # The following parameters can be set:
      #
      # * limit: the maximum amount of words to retrieve, set to 100 by
      #   default.
      # * offset: the row offset to use when limiting the dataset.
      # * channel: the channel for which to retrieve the words.
      # * nick: the nick of a word author. When set only the words added by
      #   this particular user will be displayed.
      #
      # @since 2012-07-06
      #
      get '/' do
        content_type 'application/json'

        limit  = params[:limit]  || 100
        offset = params[:offset] || 0
        words  = Model::Word.limit(limit, offset)

        if params[:channel]
          words = words.filter(:channel => params[:channel])
        end

        if params[:nick]
          words = words.filter(:nick => params[:nick])
        end

        return JSON.dump(words.map(&:values))
      end

      ##
      # Retrieves the details of a single word.
      #
      # @since 2012-07-06
      #
      get '/:id' do
        content_type 'application/json'

        word = Model::Word[params[:id]]

        if word
          return JSON.dump(word.values)
        else
          status 404

          return JSON.dump(:message => 'The word does not exist')
        end
      end
    end # Words
  end # Controller
end # Hermes
