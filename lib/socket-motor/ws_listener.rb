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
         
        channel_name   = message.body[:channel_name]
        
        case message.name
        when 'control'
          connection_id  = message.body[:connection_id]
          connection     = WSConnection.find_by_connection_id(connection_id)
           
          case message.body[:operation]
          when 'subscribe'
            connection.subscribe(channel_name)
            
            log_debug "Subscribed '#{connection_id}' to '#{channel_name}'"
          when 'unsubscribe'
            connection.unsubscribe(channel_name)
            
            log_debug "Unsubscribed '#{connection_id}' to '#{channel_name}'"
          end
        when 'publish'
          message = message.body[:message]
          WSConnection.publish_to_channel(channel_name, message)
          
          log_debug "Published '#{message}' to '#{channel_name}'"
        end
      end
    end

   
    def channel_unsubscribe(channel_name, signature)
      unless channel_subscribed? channel_name, conn
        log_warn "Cannot unsubscribe #{conn.signature} to channel #{channel_name}, not a subscriber"
      end
       
      chan_meta @channels[channel_name]
      sid = chan_meta[:connection_ids][connection_id(conn.signature)]
      chan_meta[:em_channel].unsubscribe sid
      
      log_debug "Unsubscribed #{conn.signature} from #{channel_name}"
      sid
    end

    def channel_subscribed?(channel_name, conn)
      !!@channels[channel_name][:connection_ids][connection_id(conn.signature)]
    end

    def setup_websockets
      ws_in.on_open do |conn|
        ws_conn = WSConnection.new(conn)
        
        log_debug "WS connected #{ws_conn.connection_id}"
      end
      ws_in.on_close do |conn|
        ws_conn = WSConnection.find_by_em_connection(conn)
        ws_conn.teardown
         
        log_debug "WS closed #{ws_conn.connection_id}"
      end
      ws_in.on_error do |reason,conn|
        ws_conn = WSConnection.find_by_em_connection(conn)
        ws_conn.teardown
         
        log_debug "WS error #{ws_conn.connection_id}: #{reason.inspect}"
      end
      ws_in.on_recv do |message,conn|
        log_debug "WS Recv #{message.name}"
         
        ws_conn = WSConnection.find_by_em_connection(conn)
        
        message_hash = message.to_hash.merge({'head' => {'message_class' => nil}})
        req_message = SocketMotor::ReqRepMessage.from_hash(message_hash)
        req_message.connection_id = ws_conn.connection_id
         
        proxy_out.send_message(req_message) do |resp_message|
          log_debug "Recvd resp_message #{resp_message.inspect}, sending back to client"
          
          conn.send_message(resp_message)
        end
      end
    end
  end
end
