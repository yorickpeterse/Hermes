desc 'Runs all the tests'
task :test do
  Dir[File.expand_path('../../spec/hermes/**/*.rb', __FILE__)].each do |file|
    require file
  end
end
