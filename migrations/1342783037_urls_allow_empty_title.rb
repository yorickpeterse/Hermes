Sequel.migration do
  up do
    alter_table :urls do
      set_column_allow_null(:title, true)
    end
  end

  down do
    alter_table :urls do
      set_column_allow_null(:title, false)
    end
  end
end
