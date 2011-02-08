class SocketMotor
  #TODO: Finish this
  class ChannelMaster < DripDrop::Node::Nodelet
    include LogBroadcaster
    
    def run
      channels_in.on_recv do |message,response|
        log_debug "Recevied chan req"
        channels_out.send_message(message)
        
        response.send_message(:name => 'ack')
      end
    end
  end
end
