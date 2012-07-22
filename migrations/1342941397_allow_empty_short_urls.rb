Sequel.migration do
  up do
    alter_table :urls do
      set_column_allow_null(:short_url, true)
    end
  end

  down do
    alter_table :urls do
      set_column_allow_null(:short_url, false)
    end
  end
end
