namespace :import do
  desc 'Imports data from a Skybot SQLite3 database'
  task :skybot, :db do |task, args|
    require APP

    connection = Sequel.connect(
      :adapter  => 'sqlite',
      :database => File.expand_path(args.db),
      :encoding => 'utf8',
      :test     => true
    )

    quotes   = []
    weather  = []
    words    = []

    connection[:quote].each do |row|
      quotes << {
        :nick        => row[:nick],
        :author_nick => row[:add_nick],
        :channel     => row[:chan],
        :quote       => row[:msg],
        :created_at  => Time.at(row[:time])
      }
    end

    connection[:weather].each do |row|
      weather << {
        :nick       => row[:nick],
        :channel    => '#forrst-chat',
        :location   => row[:loc],
        :created_at => Time.now
      }
    end

    connection[:memory].each do |row|
      words << {
        :word       => row[:word],
        :channel    => row[:chan],
        :text       => row[:data],
        :nick       => row[:nick],
        :created_at => Time.now
      }
    end

    Hermes::Model::Quote.multi_insert(quotes)
    Hermes::Model::WeatherLocation.multi_insert(weather)
    Hermes::Model::Word.multi_insert(words)

    connection.disconnect
  end
end
