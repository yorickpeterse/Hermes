module Hermes
  module Plugin
    ##
    # Plugin that allows users to store words and custom text associated with
    # these words. This text can be URLs, descriptions, shell commands, etc.
    #
    class Remember
      include Cinch::Plugin

      set :help => 'rem [WORD] [TEXT] - Stores the text for the given word' \
        ' | ?[WORD] - Displays the text of the specified word',
        :plugin_name => 'rem'

      match /rem\s+(\S+)\s+(.+)/, :method => :set
      match /\?(\S+)\s*(\S*)/, :method => :get, :prefix => ''

      ##
      # Stores a new word or updates an existing one.
      #
      # @param [Cinch::Message] message
      # @param [String] word The word to remember.
      # @param [String] text The text of the word.
      #
      def set(message, word, text)
        channel  = message.channel.to_s
        nick     = message.user.nick.to_s
        existing = Model::Word[:word => word, :channel => channel]

        if existing
          existing_value = existing.text

          existing.update(:text => text)

          message.reply(
            %Q{forgetting "#{existing_value}", remembering this instead},
            true
          )
        else
          Model::Word.create(
            :nick    => nick,
            :channel => channel,
            :word    => word,
            :text    => text
          )

          message.reply('done', true)
        end
      end

      ##
      # Retrieves a word from the database.
      #
      # @param [Cinch::Message] message
      # @param [String] word The word for which to retrieve the text.
      # @param [String] prefix A string that has to be displayed before the
      #  word's text.
      #
      def get(message, word, prefix)
        row = Model::Word[:word => word, :channel => message.channel.to_s]

        if row
          if !prefix.empty?
            message.reply(prefix + ': ' + row.text)
          else
            message.reply(row.text, true)
          end
        else
          message.reply('The specified word was not found', true)
        end
      end
    end # Word
  end # Plugin
end # Hermes
