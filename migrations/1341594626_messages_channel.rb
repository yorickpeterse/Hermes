Sequel.migration do
  up do
    add_column :messages, :channel, String
  end

  down do
    drop_column :messages, :channel
  end
end
