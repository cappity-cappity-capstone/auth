require 'rake'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'sinatra/activerecord/rake'

SHA = `git rev-parse --short HEAD`.strip.freeze

desc 'Run the application specs'
RSpec::Core::RakeTask.new(:spec)

desc 'Run the quality metrics'
RuboCop::RakeTask.new(:quality) do |cop|
  cop.patterns = ['app/**/*.rb', 'spec/**/*.rb']
end

namespace :db do
  desc 'Load the database configuration for Auth'
  task :load_config do
    ENV['APP_ENV'] ||= 'development'
    ActiveRecord::Base.configurations = YAML.load_file('config/database.yml')
    ActiveRecord::Base.establish_connection(ENV['APP_ENV'].to_sym)
  end
end

task app_environment: 'db:load_config' do
  $LOAD_PATH << File.expand_path('app', '.')
  require 'auth'
end

task environment: %w(db:load_config app_environment)

desc 'Open a Pry console with the application loaded and database set'
task shell: :environment do
  Pry.config.prompt_name = 'auth'
  Pry.start
end

desc 'Run the web server'
task web: :environment do
  ENV['RACK_ENV'] = ENV['APP_ENV']
  unicorn_conf = { config_file: 'unicorn.rb' }
  app = Unicorn.builder('config.ru', unicorn_conf)
  Unicorn::HttpServer.new(app, unicorn_conf).start.join
end

desc 'Run the Docker build'
task :docker do
  system("docker build -t auth:#{SHA} .") || fail('Unable to build auth')
  system("docker tag -f auth:#{SHA} auth:latest") || fail('Unable to tag docker image')
end

desc 'Run the specs and quality metrics'
task default: [:spec, :quality]
