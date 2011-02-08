class SocketMotor
  #TODO: Finish this
  class ChannelMaster < DripDrop::Node::Nodelet
    include LogBroadcaster
    
    def run
      channels_in.on_recv do |message,response|
        log_debug "Received channel message #{message.inspect}"
        begin
          channels_out.send_message(message)
          
          response.send_message(:name => 'ack')
        rescue StandardError => e
          log_fatal "Error processing channel request #{e.message}, #{e.backtrace.join("\n")}"
        end
      end
    end
  end
end
