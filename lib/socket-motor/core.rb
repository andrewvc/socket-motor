require 'dripdrop'
Thread.abort_on_exception = true

class SocketMotor
  class ProxyMaster < DripDrop::Node::Nodelet
    def run
      proxy_reqs
    end

    def proxy_reqs
      proxy_in.on_recv do |message, response|
        puts "Proxying #{message.inspect} to htout"
        proxy_out.send_message(message) do |http_response|
          puts "Received http response #{http_response.inspect} sending back"
          response.send_message(http_response)
        end
      end
    end
  end

  class BroadcastMaster < DripDrop::Node::Nodelet
    def run
      heartbeat
    end
    
    def heartbeat
      EM::PeriodicTimer.new(1) do
        broadcast_out.send_message :name => 'tick', :body => Time.now.to_s
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
        puts "Broadcast In recv: #{message.inspect}"
        @channel_all.push(message)
      end
    end

    def setup_websockets
      sigs_sids = {} #Map connection signatures to subscriber IDs
       
      websocket.on_open do |conn|
        puts "WS Connected"
        conn.send_message(DripDrop::Message.new('test'))
        
        sid = @channel_all.subscribe do |message|
          puts message.inspect
          conn.send_message(message)
        end
         
        sigs_sids[conn.signature] = sid
      end
      websocket.on_close do |conn|
        puts "Closed #{conn.signature}"
        @channel_all.unsubscribe sigs_sids[conn.signature]
      end
      websocket.on_error do |reason,conn|
        puts "Errored #{reason.inspect}, #{conn.signature}"
        @channel_all.unsubscribe sigs_sids[conn.signature]
      end

      websocket.on_recv do |message,conn|
        puts "WS Recv #{message.name}"
        @reqs_out.send_message(message) do |resp_message|
          puts "Recvd resp_message #{resp_message.inspect}, sending back to client"
          conn.send_message(resp_message)
        end
      end
    end
  end   
end
