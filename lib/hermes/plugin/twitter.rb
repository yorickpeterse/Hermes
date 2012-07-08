module Hermes
  module Plugin
    ##
    # Plugin for retrieving tweets based on usernames, hash tags or tweet IDs.
    #
    # @since 2012-07-08
    #
    class Twitter
      include Cinch::Plugin

      match /tw\s+(.+)/,      :method => :execute
      match /twitter\s+(.+)/, :method => :execute

      set :help => 'tw/twitter [USERNAME|HASH TAG|TWEET ID] - ' \
        'Retrieves the latest tweet from a user, hash tag or tweet ID',
        :plugin_name => 'twitter'


      ##
      # Retrieves a tweet.
      #
      # @since 2012-07-08
      # @param [Cinch::Message] message
      # @param [String] identifier A tweet ID, hash tag or username for which
      #  to retrieve a tweet.
      #
      def execute(message, identifier)
        begin
          if identifier =~ /^\d+$/
            tweet = ::Twitter.status(identifier)
          elsif identifier[0] == '#'
            tweet = ::Twitter.search(identifier, :rpp => 1).results[0]
          else
            tweet = ::Twitter.user_timeline(identifier, :count => 1)[0]
          end
        rescue => e
          message.reply("Failed to retrieve the tweet: #{e.message}", true)

          return
        end

        if !tweet
          message.reply('No tweet was found', true)

          return
        end

        # Determine the username of the tweet.
        if tweet.respond_to?(:user) and tweet.user
          screen_name = tweet.user.screen_name
        elsif tweet.respond_to?(:from_user)
          screen_name = tweet.from_user
        else
          screen_name = 'Unknown'
        end

        reply = '%s %s: %s' % [
          tweet.created_at.strftime(Hermes::DATE_TIME_FORMAT),
          screen_name,
          tweet.text
        ]

        message.reply(reply, true)
      end
    end # Twitter
  end # Plugin
end # Hermes
