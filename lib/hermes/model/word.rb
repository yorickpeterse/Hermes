module Hermes
  module Model
    ##
    # Model used for storing words and the text associated with these words.
    #
    #
    class Word < Sequel::Model
      plugin :timestamps, :created => :created_at, :updated => :updated_at

      ##
      # Validates the instance before creating or saving a record.
      #
      #
      def validate
        validates_presence([:word, :channel, :text, :nick])
      end
    end # Quote
  end # Model
end # Hermes
