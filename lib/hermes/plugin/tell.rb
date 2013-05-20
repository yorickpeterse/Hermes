module Hermes
  module Plugin
    ##
    # Plugin that allows users to store messages in the bot's database. These
    # messages will be sent to a user the next time he/she speaks in a channel.
    #
    class Tell
      include Cinch::Plugin

      set :help => 'tell [USER] [MESSAGE] - Stores a message for the ' \
        'given user',
        :plugin_name => 'tell'

      listen_to :message

      match /tell\s+(\S+)\s+(.+)/

      ##
      # Checks if there's a message stored for the user that wrote the
      # message. If this is the case the message will be sent to the user as a
      # private message.
      #
      # The messages database table is only checked if 5 seconds have passed
      # between the current and last message in order to reduce the load.
      #
      # @param [Cinch::Message] message
      #
      def listen(message)
        @last_time ||= Time.now.to_i

        return if Time.now.to_i - @last_time <= 5

        nick = message.user.nick

        Model::Message.filter(:receiver_nick => nick).each do |row|
          priv_message = 'Message from %s in %s on %s: %s' % [
            row.nick,
            row.channel,
            row.created_at.strftime(Hermes::DATE_TIME_FORMAT),
            row.message
          ]

          message.user.send(priv_message)

          row.destroy
        end

        @last_time = Time.now.to_i
      end

      ##
      # Stores a message for a user.
      #
      # @param [Cinch::Message] message
      # @param [String] nick The nick of the receiver.
      # @param [String] text The message to store.
      #
      def execute(message, nick, text)
        begin
          msg = Model::Message.create(
            :nick          => message.user.nick,
            :receiver_nick => nick,
            :message       => text,
            :channel       => message.channel.to_s
          )

          message.reply("I'll pass that along", true)
        rescue => e
          message.reply("Failed to store the message: #{e.message}", true)
        end
      end
    end # Tell
  end # Plugin
end # Hermes
