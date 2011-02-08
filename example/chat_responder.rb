require 'socket-motor/rack_app'
require 'socket-motor/channel_agent'

#CHAN_AGENT = SocketMotor::ChannelAgent.new
#CHAN_AGENT.configure(:channel_address => 'http://127.0.0.1:2206')
#Thread.new { CHAN_AGENT.start }

class ChatResponder < SocketMotor::RackApp
  def action(message)
    # All clients have a globally unique connection ID
    connection_id = message.connection_id
     
    case message.name
    when 'chat'
      puts "Received chat message #{message.body}"

      # You must respond with either a SocketMotor::ReqRepMessage
      # or a Hash with at least :name set
      return {:name => 'ack', 
              :body => "Chat message received from #{connection_id}"}
    else
      return {:name => 'error',
              :body => "Unknown message type '#{message.name}'"}
    end
  end
end
