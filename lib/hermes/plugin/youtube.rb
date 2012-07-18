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

      ##
      # Retrieves the first video for the given search query.
      #
      # @since 2012-07-09
      # @param [Cinch::Message] message
      # @param [String] query The search query to run.
      #
      def execute(message, query)
        @youtube ||= YouTubeIt::Client.new
        response   = @youtube.videos_by(:query => query, :per_page => 1)

        if response.videos.length > 0
          video    = response.videos[0]
          rating   = '%.2f/%.1f' % [video.rating.average, video.rating.max]
          duration = ''

          # Convert the duration (which is in seconds) into a human readable
          # format.
          if video.duration <= 60
            duration = '%is' % video.duration
          elsif video.duration <= 3600
            duration = '%im' % video.duration / 60
          else
            duration = '%.2fh' % (video.duration.to_f / 3600)
          end

          reply  = '%s - length %s - rated %s - %s views - by %s on %s - %s' % [
            video.title,
            duration,
            rating,
            video.view_count,
            video.author.name,
            video.uploaded_at.strftime(Hermes::DATE_TIME_FORMAT),
            video.player_url
          ]

          message.reply(reply, true)
        else
          message.reply('No videos were found', true)
        end
      end
    end # Youtube
  end # Plugin
end # Hermes
