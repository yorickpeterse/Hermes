Sequel.migration do
  up do
    create_table :urls do
      primary_key :id

      String :url,:null => false
      String :short_url, :null => false
      String :title, :null => false
      String :channel, :null => false
      String :nick, :null => false
      String :last_nick

      Integer :times_posted, :null => false, :default => 1

      Time :created_at
      Time :updated_at
      Time :last_posted_at
    end
  end

  down do
    drop_table :urls
  end
end
