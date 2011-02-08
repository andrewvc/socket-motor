$LOAD_PATH << '../lib'
require './chat_responder'
require './example_rack_app'

use Rack::Static, :urls => ['/swf', '/js'], :root => 'public'

run Rack::URLMap.new(
  "/chat_responder" => ChatResponder.new,
  "/"               => ExampleRackApp.new
)
