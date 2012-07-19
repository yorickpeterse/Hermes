module Hermes
  module Plugin
    ##
    # Plugin that allows users to query Youtube and retrieves video details
    # whenever a link to Youtube is posted.
    #
    # @since 2012-07-09
    #
    class Youtube
      include Cinch::Plugin

      set :help => 'y/youtube [QUERY] - Retrieves the first Youtube movie ' \
        'for the query',
        :plugin_name => 'youtube'

      match /y\s+(.+)/,       :method => :execute
      match /youtube\s+(.+)/, :method => :execute

      listen_to :message

      ##
      # The Youtube client to use.
      #
      # @since  2012-07-18
      # @return [YouTubeIt::Client]
      #
      CLIENT = YouTubeIt::Client.new

      ##
      # Array of domain names to use for determining if a URL is a regular URL
      # or a Youtube URL.
      #
      # @since  2012-07-18
      # @return [Array]
      #
      YOUTUBE_HOSTS = [
        'youtube.com',
        'youtu.be',
        'www.youtube.com',
        'www.youtu.be'
      ]

      ##
      # Retrieves the first video for the given search query.
      #
      # @since 2012-07-09
      # @param [Cinch::Message] message
      # @param [String] query The search query to run.
      #
      def execute(message, query)
        response = CLIENT.videos_by(:query => query, :per_page => 1)

        if response.videos.length > 0
          message.reply(video_description(response.videos[0]), true)
        else
          message.reply('No videos were found', true)
        end
      end

      ##
      # Retrieves the description of a Youtube video whenever a Youtube URL is
      # pasted into a channel.
      #
      # @since 2012-07-18
      # @param [Cinch::Message] message
      #
      def listen(message)
        msg = message.message

        return if msg !~ /youtube/ and msg !~ /youtu\.be/

        extracted = URI.extract(msg).map { |u| u.chomp('/') }

        extracted.each do |url|
          parsed = URI.parse(url)

          if !YOUTUBE_HOSTS.include?(parsed.host) or parsed.query.nil?
            next
          end

          # Extract the video ID
          query = CGI.parse(parsed.query)

          if query['v']
            video = CLIENT.video_by(query['v'][0])

            message.reply(video_description(video), true)
          end
        end
      end

      ##
      # Returns the description of a Youtube movie.
      #
      # @since 2012-07-18
      # @param [YouTubeIt::Model::Video] video The video for which to generate
      #  a description.
      # @return [String]
      #
      def video_description(video)
        rating   = '%.2f/%.1f' % [video.rating.average, video.rating.max]
        duration = '0s'

        # Convert the duration (which is in seconds) into a human readable
        # format.
        if video.duration <= 60
          duration = '%is' % video.duration
        elsif video.duration <= 3600
          duration = '%im' % (video.duration / 60)
        else
          duration = '%.2fh' % (video.duration.to_f / 3600)
        end

        return '%s - length %s - rated %s - %s views - by %s on %s - %s' % [
          video.title,
          duration,
          rating,
          video.view_count,
          video.author.name,
          video.uploaded_at.strftime(Hermes::DATE_TIME_FORMAT),
          video.player_url
        ]
      end
    end # Youtube
  end # Plugin
end # Hermes
