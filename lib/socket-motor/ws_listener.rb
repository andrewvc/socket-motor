class SocketMotor
  class WSListener < DripDrop::Node::Nodelet
    include LogBroadcaster
    
    def run
      @channel_all = EM::Channel.new
      
      setup_websockets
      setup_broadcast
    end

    def setup_broadcast
      # Receives messages from Broadcast Out
      broadcast_in.on_recv do |message|
        log_debug "Broadcast In recv: #{message.inspect}"
        @channel_all.push(message)
      end
    end

    def setup_websockets
      sigs_sids = {} #Map connection signatures to subscriber IDs

      ws_in.on_open do |conn|
        log_debug "WS Connected"
        conn.send_message(DripDrop::Message.new('test'))
        
        sid = @channel_all.subscribe do |message|
          log_debug message.inspect
          conn.send_message(message)
        end
         
        sigs_sids[conn.signature] = sid
      end
      ws_in.on_close do |conn|
        log_debug "Closed #{conn.signature}"
        @channel_all.unsubscribe sigs_sids[conn.signature]
      end
      ws_in.on_error do |reason,conn|
        log_warn "Errored #{reason.inspect}, #{conn.signature}"
        @channel_all.unsubscribe sigs_sids[conn.signature]
      end

      ws_in.on_recv do |message,conn|
        log_debug "WS Recv #{message.name}"
        @reqs_out.send_message(message) do |resp_message|
          log_debug "Recvd resp_message #{resp_message.inspect}, sending back to client"
          conn.send_message(resp_message)
        end
      end
    end
  end   
end
