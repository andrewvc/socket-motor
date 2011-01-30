require 'rubygems'
require 'sinatra'
require 'net/http'
require 'dripdrop/message'
require 'haml'

get '/' do
  haml :index
end

post '/proxy_point' do
  message = DripDrop::Message.decode_json(request.body.read)

  http = Net::HTTP.new('127.0.0.1', 2203)
  http.post '/', message.json_encoded, {}
   
  DripDrop::Message.new('ack').json_encoded
end
