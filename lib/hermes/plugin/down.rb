module Hermes
  module Plugin
    ##
    # Checks if a given website is responding or not using a HEAD request.
    #
    # @since 2012-06-27
    #
    class Down
      include Cinch::Plugin

      set :help => 'down [HOST] - Checks if a website is down or not.',
        :plugin_name => 'down'

      match /down\s+(\S+)/

      ##
      # Executes the plugin.
      #
      # @since 2012-06-27
      # @param [Cinch::Message] message
      # @param [String] url The URL to check.
      #
      def execute(message, url)
        begin
          response = HTTParty.head(url)
        rescue => e
          message.reply(
            "The URL #{url} doesn't seem to be working: #{e.message}",
            true
          )

          return
        end

        if response.success?
          message.reply("The URL #{url} seems to be working fine", true)
        else
          message.reply(
            "The URL #{url} doesn't seem to be working. " \
              "HTTP response: #{response.status} #{response.message}",
            true
          )
        end
      end
    end # Down
  end # Plugin
end # Hermes
