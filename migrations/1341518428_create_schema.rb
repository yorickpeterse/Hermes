Sequel.migration do
  up do
    create_table :quotes do
      primary_key :id

      String :channel, :null => false
      String :nick, :null => false
      String :author_nick, :null => false
      String :quote, :text => true, :null => false

      Time :created_at
      Time :updated_at
    end

    create_table :messages do
      primary_key :id

      String :nick, :null => false
      String :receiver_nick, :null => false
      String :message, :text => true, :null => false

      Time :created_at
    end

    create_table :weather_locations do
      primary_key :id

      String :nick, :null => false
      String :channel, :null => false
      String :location, :null => false

      Time :created_at
      Time :updated_at
    end

    create_table :words do
      primary_key :id

      String :word, :null => false
      String :channel, :null => false
      String :text, :null => false
      String :nick, :null => false

      Time :created_at
      Time :updated_at
    end
  end

  down do
    drop_table :quotes
    drop_table :messages
    drop_table :weather_locations
    drop_table :words
  end
end
