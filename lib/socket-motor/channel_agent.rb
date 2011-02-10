require 'dripdrop'

class SocketMotor
  class ChannelAgent < DripDrop::Node
    def configure(opts={})
      @opts = opts
    end
     
    def action
      route :channel_out, :http_client, @opts[:channel_address], :message_class => SocketMotor::ChannelMessage
    end
    
    def publish(channel_name, message)
      channel_out.send_message(SocketMotor::ChannelMessage.publish_message(channel_name, message)) do |resp_message|
        puts resp_message
      end
    end
    
    def subscribe(channel_name, connection_id)
      channel_out.send_message SocketMotor::ChannelMessage.subscribe_message(channel_name, connection_id) do |resp_message|
        puts resp_message
      end

    end
        
    def unsubscribe(channel_name, connection_id)
      channel_out.send_message SocketMotor::ChannelMessage.publish_message(channel_name, connection_id) do |resp_message|
        puts resp_message
      end
    end
  end
end
