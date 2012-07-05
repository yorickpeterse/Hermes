namespace :db do
  desc 'Generates a migration file'
  task :migration, :name do |task, args|
    name   = Time.new.to_i.to_s + '_' + args[:name] + '.rb'
    handle = File.open(File.join(MIGRATIONS, name), 'w')

    handle.write <<-TXT
Sequel.migration do
  up do

  end

  down do

  end
end
    TXT

    handle.close
  end

  desc 'Migrates the database to the most recent version'
  task :migrate do
    require APP

    Sequel::Migrator.run(Hermes.database, MIGRATIONS)
  end

  desc 'Reverts to the specified migration'
  task :revert, :target do |task, args|
    require APP

    Sequel::Migrator.run(Hermes.database, MIGRATIONS, :target => args[:target])
  end
end
