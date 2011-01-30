require 'dripdrop'
Thread.abort_on_exception = true

class SocketMotor
  class ProxyMaster < DripDrop::Node::Nodelet
    def run
      proxy_reqs
    end

    def proxy_reqs
      proxy_in.on_recv do |message, response|
        SocketMotor.logger.debug "Proxying #{message.inspect} to htout"
         
        proxy_out.send_message(message) do |http_response|
          SocketMotor.logger.debug "Received http response #{http_response.inspect} sending back"
          response.send_message(http_response)
        end
      end
    end
  end

  class BroadcastMaster < DripDrop::Node::Nodelet
    def run
      broadcast_in.on_recv do |message,response|
        broadcast_out.send_message(message)
        response.send_message(:name => 'message_sent')
      end
    end
  end

  class WSListener < DripDrop::Node::Nodelet
    def run
      @channel_all = EM::Channel.new
      
      setup_websockets
      setup_broadcast
    end

    def setup_broadcast
      # Receives messages from Broadcast Out
      broadcast_in.on_recv do |message|
        SocketMotor.logger.debug "Broadcast In recv: #{message.inspect}"
        @channel_all.push(message)
      end
    end

    def setup_websockets
      sigs_sids = {} #Map connection signatures to subscriber IDs

      ws_in.on_open do |conn|
        SocketMotor.logger.debug "WS Connected"
        conn.send_message(DripDrop::Message.new('test'))
        
        sid = @channel_all.subscribe do |message|
          SocketMotor.logger.debug message.inspect
          conn.send_message(message)
        end
         
        sigs_sids[conn.signature] = sid
      end
      ws_in.on_close do |conn|
        SocketMotor.logger.debug "Closed #{conn.signature}"
        @channel_all.unsubscribe sigs_sids[conn.signature]
      end
      ws_in.on_error do |reason,conn|
        SocketMotor.logger.warn "Errored #{reason.inspect}, #{conn.signature}"
        @channel_all.unsubscribe sigs_sids[conn.signature]
      end

      ws_in.on_recv do |message,conn|
        SocketMotor.logger.debug "WS Recv #{message.name}"
        @reqs_out.send_message(message) do |resp_message|
          SocketMotor.logger.debug "Recvd resp_message #{resp_message.inspect}, sending back to client"
          conn.send_message(resp_message)
        end
      end
    end
  end   
end
