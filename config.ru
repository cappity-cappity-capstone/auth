constants = Auth::Controllers.constants.map(&Auth::Controllers.method(:const_get))
controllers = constants.select { |const| const.is_a?(Class) && (const < Sinatra::Base) }
run Rack::Cascade.new(controllers)

