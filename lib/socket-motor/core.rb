require 'dripdrop'

Thread.abort_on_exception = true

class SocketMotor
  include LogBroadcaster
   
  class ProxyMaster < DripDrop::Node::Nodelet
    def run
      proxy_reqs
    end

    def proxy_reqs
      proxy_in.on_recv do |message, response|
        SocketMotor.log_debug "Proxying #{message.inspect} to htout"
         
        proxy_out.send_message(message) do |http_response|
          SocketMotor.log_debug "Received http response #{http_response.inspect} sending back"
          response.send_message(http_response)
        end
      end
    end
  end

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

  class LogReceiver < DripDrop::Node::Nodelet
    attr_accessor :console_logger

    def run
      @console_logger = Logger.new(STDERR)
      @console_logger.level = Logger::DEBUG
      
      logger_in.on_recv do |message|
        case message.name
        when 'log'
          b = message.body
          formatted = "|#{b['origin_nodelet']}| #{b['message']}"
          @console_logger.send(b['level'],formatted)
        end
      end
    end

    def debug(message); @console_logger.debug message; end
    def info(message);  @console_logger.info  message;  end
    def warn(message);  @console_logger.warn  message; end
    def fatal(message); @console_logger.fatal message; end
  end
end
