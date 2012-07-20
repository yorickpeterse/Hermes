desc 'Creates the required configuration files'
task :config do
  require 'fileutils'

  dir = File.expand_path('../../config', __FILE__)

  Dir[File.join(dir, '*.default.rb')].each do |file|
    basename = File.basename(file)
    new_name = basename.gsub('default.', '')
    new_file = File.join(dir, new_name)

    FileUtils.cp(file, new_file)
  end

  puts "Created the configuration files, don't forget to modify them."
end
