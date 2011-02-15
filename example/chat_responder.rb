require 'socket-motor/rack_app'
require 'socket-motor/channel_agent'

Thread.abort_on_exception = true

CHAN_AGENT = SocketMotor::ChannelAgent.new
CHAN_AGENT.configure(:channel_address => 'http://127.0.0.1:2206')

Thread.new { 
  puts "Starting EM"
  EM::run { CHAN_AGENT.action }
  puts "Started"
}


class ChatResponder < SocketMotor::RackApp
  handle 'chat' do |message|
    begin
      # All clients have a globally unique connection ID
      # message.connection_id
   
      puts "Received chat message #{message.body}"
      
      EM::next_tick do
        CHAN_AGENT.publish('test', 'broadcasted BLAH BLAH')
      end
       
      puts "Publishing to channel"

      # You must respond with either a SocketMotor::ReqRepMessage
      # or a Hash with at least :name set
      {:name => 'ack_chat', 
       :body => "Chat message received from #{message.connection_id}"}
    rescue StandardError => e
      puts e.inspect
    end
  end

  handle 'channel_subscribe' do |message|
    channel_name = message.body['channel_name']
    puts "Subscribing to channel #{channel_name}. #{message.inspect}"
    
    EM::next_tick do
      CHAN_AGENT.subscribe(channel_name, message.connection_id)
    end
    
    {:name => 'ack_subscribe'}
  end
  
  # Fallback route
  def action(message)
      {:name => 'error',
       :body => "Unknown message type '#{message.name}'"}
  end
end
