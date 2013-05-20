module Hermes
  module Plugin
    ##
    # Plugin that allows users to store quotes of other users.
    #
    class Quote
      include Cinch::Plugin

      set :help => 'q/quote add [NICK] [QUOTE] - Adds a new quote for ' \
        'the user | q/quote [CHANNEL] [NICK] [NUMBER] - Displays either a ' \
        'randomly selected quote or the nth quote of a user',
        :plugin_name => 'quote'

      match(/q\s+(.+)/,     :method => :execute)
      match(/quote\s+(.+)/, :method => :execute)

      ##
      # IRC users that require some extra care.
      #
      # @return [Array]
      #
      SPECIAL_USERS = ['davzie']

      ##
      # Regex to use for matching commands that should store new quotes.
      #
      # @return [Regexp]
      #
      SET_REGEX = /add\s+(\S+)\s+(.+)/

      ##
      # Regex to use for matching commands that should retrieve existing
      # quotes.
      #
      # @return [Regexp]
      #
      GET_REGEX = /(\#{1,2}\S+\s+)*(\S+)\s*(\d*)/

      ##
      # Executes the plugin and determines whether a quote should be stored or
      # displayed.
      #
      # @param [Cinch::Message] message
      # @param [String] command The quote command.
      #
      def execute(message, command)
        if command =~ /^add/
          matches = command.scan(SET_REGEX)
          method  = :set
        else
          matches = command.scan(GET_REGEX)
          method  = :get
        end

        if matches and !matches.empty?
          send(method, message, *matches[0])
        end
      end

      private

      ##
      # Stores a new quote.
      #
      # @param [Cinch::Message] message
      # @param [String] nick The nick of the user for which to add the quote.
      # @param [String] quote The quote to add.
      #
      def set(message, nick, quote)
        author   = message.user.nick.to_s
        channel  = message.channel.to_s
        existing = Model::Quote[
          :nick    => nick,
          :channel => channel,
          :quote   => quote
        ]

        if existing
          reply = 'The specified quote already exists.'

          if SPECIAL_USERS.include?(nick)
            reply += " Have you not learned already #{nick}?"
          end

          message.reply(reply, true)
        else
          Model::Quote.create(
            :nick        => nick,
            :author_nick => author,
            :channel     => channel,
            :quote       => quote
          )

          message.reply('The quote has been added', true)
        end
      end

      ##
      # Retrieves a random or specific quote of the specified user.
      #
      # @param [Cinch::Message] message
      # @param [String] channel The channel of the quote.
      # @param [String] nick The name of the user for which to retrieve a
      #  quote.
      # @param [String] number The number of the quote to retrieve.
      #
      def get(message, channel, nick, number)
        channel ||= message.channel.to_s
        channel   = channel.strip
        quotes    = Model::Quote.filter(:channel => channel, :nick => nick) \
          .all

        if !quotes.empty?
          if !number.empty?
            index = number.to_i - 1
          else
            index = (0..quotes.length - 1).to_a.sample
          end

          if quotes[index]
            quote = quotes[index]
            date  = quote.created_at.strftime(Hermes::DATE_TIME_FORMAT)
            reply = '[%i/%i] %s <%s> %s' \
              % [index + 1, quotes.length, date, quote.nick, quote.quote]

            message.reply(reply, true)
          else
            message.reply('No quote was found', true)
          end
        else
          message.reply('No quotes were found for the user', true)
        end
      end
    end # Quote
  end # Plugin
end # Hermes
