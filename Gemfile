source 'https://rubygems.org'

gem 'rake', '~> 10.4.2'
gem 'sinatra', git: 'https://github.com/sinatra/sinatra'
gem 'activerecord', '~> 4.2.0'
gem 'unicorn', '~> 4.8.3'
gem 'pry', '~> 0.10.1'
gem 'sinatra-activerecord', '~> 2.0.4'

group :development, :test do
  gem 'rspec', '~> 3.1.0'
  gem 'rubocop', '~> 0.28.0'
  gem 'rack-test', '~> 0.6.3'
  gem 'database_cleaner', '~> 1.4.0'
  gem 'factory_girl', '~> 4.5.0'
  gem 'sqlite3', '~> 1.3.10'
end

group :production do
  gem 'mysql2', '~> 0.3.18'
end
