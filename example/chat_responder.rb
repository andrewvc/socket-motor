require 'socket-motor/rack_app'
require 'socket-motor/channel_agent'

CHAN_AGENT = SocketMotor::ChannelAgent.new
CHAN_AGENT.configure(:channel_address => 'http://127.0.0.1:2206')
if true
  puts "Using existing EM reactor"
  CHAN_AGENT.action
else
  puts "Starting EM"
  CHAN_AGENT.start
end

class ChatResponder < SocketMotor::RackApp
  handle 'chat' do |message|
    # All clients have a globally unique connection ID
    # message.connection_id
 
    puts "Received chat message #{message.body}"
    
    CHAN_AGENT.publish('test', 'broadcasted BLAH BLAH')
    puts "Publishing to channel"

    # You must respond with either a SocketMotor::ReqRepMessage
    # or a Hash with at least :name set
    {:name => 'ack_chat', 
     :body => "Chat message received from #{message.connection_id}"}
  end

  handle 'channel_subscribe' do |message|
    channel_name = message.body['channel_name']
    puts "Subscribing to channel #{channel_name}. #{message.inspect}"
    begin
      CHAN_AGENT.subscribe(channel_name, message.connection_id)
    rescue StandardError => e
      puts e.message
      puts e.backtrace.join("\n")
    end
    
    {:name => 'ack_subscribe'}
  end
  
  # Fallback route
  def action(message)
      {:name => 'error',
       :body => "Unknown message type '#{message.name}'"}
  end
end
