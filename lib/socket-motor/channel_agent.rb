require 'dripdrop'

class SocketMotor
  class ChannelAgent < DripDrop::Node::Nodelet
    def configure(opts={})
      @opts = opts
    end
    
    def publish(channel_name, payload)
      message = SocketMotor::ChannelMessage::Publish.new(channel_name, payload)
      channel_out.send_message(message)
    end
    
    def subscribe(channel_name, connection_id)
      message = SocketMotor::ChannelMessage::Control.new(channel_name, 'subscribe', connection_id)
      channel_out.send_message(message)
    end
        
    def unsubscribe(channel_name, connection_id)
      message = SocketMotor::ChannelMessage::Control.new(channel_name, 'unsubscribe', connection_id)
      channel_out.send_message(message)
    end
  end
end
