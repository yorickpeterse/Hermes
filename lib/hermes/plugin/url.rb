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
      # Array of URL schemes that should be extracted.
      #
      # @since  2012-07-19
      # @return [Array]
      #
      SCHEMES = ['http', 'https']

      ##
      # The minimum length of a URL before a short URL should be created.
      #
      # @since  2012-07-22
      # @return [Fixnum]
      #
      SHORTEN_LENGTH = 45

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
        extracted = URI.extract(
          message.message,
          SCHEMES
        ).map { |u| u.chomp('/') }

        # Remove URLs of which the hostnames should be ignored.
        extracted.each do |url|
          extracted.delete(url) if IGNORE.include?(URI.parse(url).host)
        end

        return if extracted.empty?

        existing = Model::URL.filter(:url => extracted, :channel => channel) \
          .all

        if !existing.empty?
          existing.each do |row|
            display_title(message, row)

            row.update(
              :last_posted_at => Time.now,
              :times_posted   => row.times_posted + 1,
              :last_nick      => message.user.nick
            )
          end
        else
          extracted.each do |url|
            begin
              display_title(message, save_url(message, url), false)
            rescue => e
              error(e.message + "\n" + e.backtrace.join("\n"))
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
        short_url = nil
        title     = url_title(url)

        if url.length >= SHORTEN_LENGTH
          short_url = shorten_url(url)
        end

        return Model::URL.create(
          :url            => url,
          :short_url      => short_url,
          :title          => title,
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
        segments = []

        if row.short_url
          segments << "Short URL: #{row.short_url}"
        end

        if row.title
          segments.unshift("URL title: #{row.title}")
        end

        if show_last_posted
          yesterday   = Time.at(Time.now.to_i - (24 * 60 * 60))
          last_posted = row.last_posted_at.to_time
          diff        = Time.now.to_i - last_posted.to_i

          if row.last_posted_at.to_time >= yesterday and diff > 5
            segments << "Last posted by %s on %s, pay attention dumbass!" % [
              row.last_nick,
              row.last_posted_at.strftime(Hermes::DATE_TIME_FORMAT)
            ]
          end
        end

        unless segments.empty?
          message.reply(segments.join(' | '))
        end
      end
    end # URL
  end # Plugin
end # Hermes
