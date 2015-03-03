constants = Auth::Controllers.constants.map(&Auth::Controllers.method(:const_get))
controllers = constants.select { |const| const.is_a?(Class) && (const < Sinatra::Base) }
map('/auth') do
  use Rack::Cors do
    allow do
      origins '*'
      resource '*', :headers => :any, :methods => [:get, :post, :put, :delete, :options]
    end
  end if ENV['APP_ENV'] == 'development'

  run Rack::Cascade.new(controllers)
end

