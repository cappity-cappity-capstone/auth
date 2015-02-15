constants = Auth::Controllers.constants.map(&Auth::Controllers.method(:const_get))
controllers = constants.select { |const| const.is_a?(Class) && (const < Sinatra::Base) }
map('/auth') { run Rack::Cascade.new(controllers) }

