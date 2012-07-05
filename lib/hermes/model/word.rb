module Hermes
  module Model
    ##
    # Model used for storing words and the text associated with these words.
    #
    # @since 2012-07-05
    #
    class Word < Sequel::Model
      plugin :timestamps, :created => :created_at, :updated => :updated_at

      ##
      # Validates the instance before creating or saving a record.
      #
      # @since 2012-07-05
      #
      def validate
        validates_presence([:word, :channel, :text, :nick])
      end
    end # Quote
  end # Model
end # Hermes
