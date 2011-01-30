class SocketMotor
  class BroadcastMaster < DripDrop::Node::Nodelet
    include LogBroadcaster
     
    def run
      broadcast_in.on_recv do |message,response|
        broadcast_out.send_message(message)
        response.send_message(:name => 'message_sent')
      end

      EM::PeriodicTimer.new(4) do
        broadcast_out.send_message(:name => 'heartbeat', :body => Time.now.to_s)
      end
    end
  end
end
