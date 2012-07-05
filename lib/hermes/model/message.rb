module Hermes
  module Model
    ##
    # Model used for storing messages that have to be sent to a user.
    #
    # @since 2012-07-05
    #
    class Message < Sequel::Model
      plugin :timestamps, :created => :created_at

      ##
      # Validates the instance before creating or saving a record.
      #
      # @since 2012-07-05
      #
      def validate
        validates_presence([:nick, :received_nick, :message])
      end
    end # Quote
  end # Model
end # Hermes
