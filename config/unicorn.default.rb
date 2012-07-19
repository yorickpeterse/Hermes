# Default configuration file for Unicorn.
working_directory File.expand_path('../../', __FILE__)
worker_processes  2
preload_app       false
listen            File.expand_path('../../tmp/unicorn.sock', __FILE__)
user              'user', 'group'
timeout           30
pid               'tmp/unicorn.pid'
