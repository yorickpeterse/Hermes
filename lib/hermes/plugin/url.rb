module Hermes
  module Plugin
    ##
    # Plugin that keeps track of the posted URLs, retrieves their titles and
    # yells at users for posting the same URL multiple times in a short
    # timespan.
    #
    # @since 2012-07-06
    #
    class URL
      include Cinch::Plugin
      include Helper::URL

      listen_to :message

      ##
      # Array of hostnames to ignore.
      #
      # @since  2012-07-18
      # @return [Array]
      #
      IGNORE = ['youtube.com', 'youtu.be', 'www.youtube.com', 'www.youtu.be']

      ##
      # Retrieves the title of the URL, shortens the URL (if needed) and yells
      # at users if the URL has already been posted.
      #
      # @since 2012-07-06
      # @param [Cinch::Message] message
      #
      def listen(message)
        return unless message.message =~ /http/

        channel   = message.channel.to_s
        extracted = URI.extract(message.message).map { |u| u.chomp('/') }

        # Remove URLs of which the hostnames should be ignored.
        extracted.each do |url|
          extracted.delete(url) if IGNORE.include?(URI.parse(url).host)
        end

        return if extracted.empty?

        existing = Model::URL.filter(:url => extracted, :channel => channel) \
          .all

        if !existing.empty?
          existing.each do |row|
            row.update(
              :last_posted_at => Time.now,
              :times_posted   => row.times_posted + 1,
              :last_nick      => message.user.nick
            )

            display_title(message, row)
          end
        else
          extracted.each do |url|
            begin
              display_title(message, save_url(message, url), false)
            rescue => e
              message.reply("Failed to process the URL: #{e.message}")
            end
          end
        end
      end

      private

      ##
      # Retrieves the title of the URL, shortens the URL and stores all this
      # data in the database.
      #
      # @since  2012-07-06
      # @param  [Cinch::Message] message
      # @param  [String] url The URL to store.
      # @return [Hermes::Model::URL]
      #
      def save_url(message, url)
        return Model::URL.create(
          :url            => url,
          :short_url      => shorten_url(url),
          :title          => url_title(url),
          :channel        => message.channel.to_s,
          :nick           => message.user.nick,
          :last_nick      => message.user.nick,
          :last_posted_at => Time.now
        )
      end

      ##
      # Displays the title and optionally the short URL of a posted URL.
      #
      # @since 2012-07-06
      # @param [Cinch::Message] message
      # @param [Hermes::Model::URL] row The URL object for which to display the
      #  title and short URL.
      # @param [TrueClass|FalseClass] show_last_posted When set to `true` the
      #  user will be notified if the URL was posted in the past 24 hours.
      #
      def display_title(message, row, show_last_posted = true)
        segments = [row.title, "Short URL: #{row.short_url}"]

        if show_last_posted
          yesterday = Time.at(Time.now.to_i - (24 * 60 * 60))

          if row.last_posted_at.to_time >= yesterday
            segments << "Last posted by %s on %s, pay attention dumbass!" % [
              row.last_nick,
              row.last_posted_at.strftime(Hermes::DATE_TIME_FORMAT)
            ]
          end
        end

        message.reply(segments.join(' | '))
      end
    end # URL
  end # Plugin
end # Hermes
