class SocketMotor
  #TODO: Finish this
  class ChannelMaster < DripDrop::Node::Nodelet
    include LogBroadcaster
    
    def run
      @channels = {
      }
       
      channels_in.on_recv do |message,response|
        channels_out.send_message(message)
        
        response.send_message(:name => 'ack')
      end
    end
  end
end
