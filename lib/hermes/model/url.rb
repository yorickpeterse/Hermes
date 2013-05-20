module Hermes
  module Model
    ##
    # Model used for storing and retrieving URLs that have been posted in an
    # IRC channel.
    #
    #
    class URL < Sequel::Model
      plugin :timestamps, :created => :created_at, :updated => :updated_at

      ##
      # Validates the model instance before saving it.
      #
      #
      def validate
        validates_presence([:url, :nick, :channel, :last_posted_at])
      end
    end # URL
  end # Model
end # Hermes
