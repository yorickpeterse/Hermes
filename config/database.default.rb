Hermes.database = Sequel.connect(
  :adapter  => 'sqlite',
  :database => File.expand_path('../../database.db', __FILE__),
  :encoding => 'utf8',
  :test     => true
)
