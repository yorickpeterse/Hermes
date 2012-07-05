module Hermes
  module Model
    ##
    # Model used for storing quotes of users in particular channels.
    #
    # @since 2012-07-05
    #
    class Quote < Sequel::Model
      plugin :timestamps, :created => :created_at, :updated => :updated_at

      ##
      # Validates the instance before creating or saving a record.
      #
      # @since 2012-07-05
      #
      def validate
        validates_presence([:nick, :author_nick, :channel, :quote])
      end
    end # Quote
  end # Model
end # Hermes
