require 'rubygems'
require 'sinatra'
require 'haml'

class ExampleRackApp < Sinatra::Base
  set :static, true
  set :logging, true
   
  get '/' do
    haml :index
  end
end

__END__

class SocketMotor
  class Controller
    def on_recv(message)
      message = SocketMotor::RequestMessage.new message
      
      channel_subscribe('test', message.connection_id)
      channel_publish('test', 'Channel alert!')    
    end
     
    def channel_subscribe
      request = Typhoeus::Request.new("http://www.pauldix.net",
                                :body          => "this is a request body",
                                :method        => :post,
                                :headers       => {:Accept => "text/html"},
                                :timeout       => 100, # milliseconds
                                :cache_timeout => 60, # seconds
                                :params        => {:field1 => "a field"}) 
    end
    def channel_publish
      send_message
    end
    def channel_unsubscribe
    end
  end
  
  class HTTPAgent
    def send_message(opts={})
     request = Typhoeus::Request.new("http://www.pauldix.net",
                                :body          => "this is a request body",
                                :method        => :post,
                                :headers       => {:Accept => "text/html"},
                                :timeout       => 100, # milliseconds
                                :cache_timeout => 60, # seconds
                                :params        => {:field1 => "a field"}) 
    end
  end
end

def subscribe_to_channel(channel_name, connection_id)
  channel_http = Net::HTTP.new('127.0.0.1', 2206)
  channel_message = DripDrop::Message.new('control', 
                      :body => {:channel_name  => channel_name, 
                                :connection_id => connection_id,
                                :operation     => 'subscribe'})
  
  channel_http.post '/', channel_message.json_encoded, {}
end

def publish_to_channel(channel_name, connection_id, message)
  channel_http = Net::HTTP.new('127.0.0.1', 2206)
  channel_message = DripDrop::Message.new('control', 
                      :body => {:channel_name  => channel_name, 
                                :connection_id => connection_id,
                                :operation     => 'subscribe'})
  
  channel_http.post '/', channel_message.json_encoded, {}
end

def broadcast_message(message)
  http = Net::HTTP.new('127.0.0.1', 2203)
  http.post '/', message.json_encoded, {}
end
