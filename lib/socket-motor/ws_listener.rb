class SocketMotor
  class WSListener < DripDrop::Node::Nodelet
    attr_reader :channel_all, :channels, :sigs_meta
     
    include LogBroadcaster
    
    def run
      @channel_all    = EM::Channel.new
      @channels       = Hash.new {|h,k| h[k] = {:em_channel => EM::Channel.new, :connection_ids => {}}}
      @sigs_meta      = {} #Map connection_ids to metadata
       
      setup_channels
      setup_websockets
    end

    def setup_channels
      channels_in.on_recv do |message|
        log_debug "Recevied channel message #{message.inspect}"
         
        case
        when message.class == SocketMotor::ChannelMessage::Control
          connection   = WSConnection.find_by_connection_id(message.connection_id)
          channel_name = message.channel_name
           
          case message.operation
          when 'subscribe'
            connection.subscribe(channel_name)
             
            log_debug "Subscribed '#{message.connection_id}' to '#{channel_name}'"
          when 'unsubscribe'
            connection.unsubscribe(channel_name)
            
            log_debug "Unsubscribed '#{message.connection_id}' to '#{channel_name}'"
          when 'kick'
            connection.close
          else
            log_warn "Unknown operation '#{message.operation}' in message #{message.inspect}"
          end
        when message.class == SocketMotor::ChannelMessage::Publish
          WSChannel.find_by_name(message.channel_name).publish(message)
        else
          log_warn "Unkown channel message type for #{message.inspect}"
        end
      end
    end

    def setup_websockets
      ws_in.on_open do |conn|
        ws_conn = WSConnection.new(conn)
        
        open_msg = SocketMotor::ReqRepMessage::Internal.new('socket_open')
        open_msg.connection_id = ws_conn.connection_id
        proxy_out.send_message(open_msg) {}
         
        log_debug "WS connected #{ws_conn.connection_id}"
      end
      ws_in.on_close do |conn|
        ws_conn = WSConnection.find_by_em_connection(conn)
        ws_conn.teardown

        close_msg = SocketMotor::ReqRepMessage::Internal.new('socket_close')
        close_msg.connection_id = ws_conn.connection_id
        proxy_out.send_message(close_msg) {}
         
        log_debug "WS closed #{ws_conn.connection_id}"
      end
      ws_in.on_error do |exception,conn|
        log_debug "WS error #{exception.message}, #{exception.backtrace.join("\n")}"
         
        begin
          ws_conn = WSConnection.find_by_em_connection(conn)
          #ws_conn.teardown

          err_msg = SocketMotor::ReqRepMessage::Internal.new('socket_error')
          proxy_out.send_message(err_msg)
        rescue Exception => e
          $stderr.write e.message + "\n"
          $stderr.write e.backtrace.join("\t\n")
        end
      end
      ws_in.on_recv do |message,conn|
        log_debug "WS Recv #{message.name}"
         
        ws_conn = WSConnection.find_by_em_connection(conn)

        message_hash = message.to_hash
        # Prevent forgery of class names
        message_hash['head']['message_class'] = nil if message_hash['head']
        req_message = SocketMotor::ReqRepMessage.from_hash(message_hash)
        req_message.connection_id = ws_conn.connection_id
         
        log_debug "Sending req message #{req_message.inspect}"
        proxy_out.send_message(req_message) do |resp_message|
          log_debug "Recvd resp_message #{resp_message.inspect}, sending back to client"
          
          conn.send_message(resp_message)
        end
      end
    end
  end
end
