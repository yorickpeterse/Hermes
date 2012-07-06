module Hermes
  module Model
    ##
    # Model used for storing and retrieving URLs that have been posted in an
    # IRC channel.
    #
    # @since 2012-07-06
    #
    class URL < Sequel::Model
      plugin :timestamps, :created => :created_at, :updated => :updated_at

      ##
      # Validates the model instance before saving it.
      #
      # @since 2012-07-06
      #
      def validate
        validates_presence(
          [:url, :short_url, :nick, :channel, :title, :last_posted_at]
        )
      end
    end # URL
  end # Model
end # Hermes
