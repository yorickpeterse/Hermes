module Hermes
  module Plugin
    ##
    # Plugin that allows users to query Youtube and retrieves video details
    # whenever a link to Youtube is posted.
    #
    class Youtube
      include Cinch::Plugin
      include Helper::Message

      set :help => 'y/youtube [QUERY] - Retrieves the first Youtube movie ' \
        'for the query',
        :plugin_name => 'youtube'

      match(/y\s+(.+)/,       :method => :execute)
      match(/youtube\s+(.+)/, :method => :execute)

      listen_to :message

      ##
      # The Youtube client to use.
      #
      # @return [YouTubeIt::Client]
      #
      CLIENT = YouTubeIt::Client.new

      ##
      # Array of domain names to use for determining if a URL is a regular URL
      # or a Youtube URL.
      #
      # @return [Array]
      #
      YOUTUBE_HOSTS = [
        'youtube.com',
        'youtu.be',
        'www.youtube.com',
        'www.youtu.be'
      ]

      ##
      # Array of URI protocols to extract.
      #
      # @return [Array]
      #
      SCHEMES = ['http', 'https']

      ##
      # Retrieves the first video for the given search query.
      #
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
      # @param [Cinch::Message] message
      #
      def listen(message)
        msg = message.message

        if (msg !~ /youtube/ and msg !~ /youtu\.be/) or plugin_command?(msg)
          return
        end

        extracted = URI.extract(msg, SCHEMES).map { |u| u.chomp('/') }

        extracted.each do |url|
          parsed = URI.parse(url)

          if !YOUTUBE_HOSTS.include?(parsed.host) or parsed.query.nil?
            next
          end

          # Extract the video ID
          query = CGI.parse(parsed.query)

          if query['v']
            video = CLIENT.video_by(query['v'][0])

            message.reply(video_description(video, false))
          end
        end
      end

      ##
      # Returns the description of a Youtube movie.
      #
      # @param [YouTubeIt::Model::Video] video The video for which to generate
      #  a description.
      # @param [TrueClass|FalseClass] include_url When set to true the URL to
      #  the video will be displayed as well.
      # @return [String]
      #
      def video_description(video, include_url = true)
        average  = video.rating.average rescue 0
        max      = video.rating.max rescue 5
        rating   = '%.2f/%.1f' % [average, max]
        duration = '0s'

        # Convert the duration (which is in seconds) into a human readable
        # format.
        if video.duration <= 60
          duration = '%is' % video.duration
        elsif video.duration <= 3600
          minutes  = video.duration.to_f / 60
          seconds  = (minutes * 60) - (minutes.to_i * 60)
          duration = '%im%is' % [minutes, seconds]
        else
          hours    = video.duration.to_f / 3600
          minutes  = (hours * 60) - (hours.to_i * 60)
          duration = '%ih%im' % [hours, minutes]
        end

        reply = '%s - length %s - rated %s - %s views - by %s on %s' % [
          video.title,
          duration,
          rating,
          video.view_count,
          video.author.name,
          video.uploaded_at.strftime(Hermes::DATE_TIME_FORMAT)
        ]

        if include_url
          reply += ' - %s' % video.player_url
        end

        return reply
      end
    end # Youtube
  end # Plugin
end # Hermes
