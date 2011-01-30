class SocketMotor
  class ProxyMaster < DripDrop::Node::Nodelet
    include LogBroadcaster
     
    def run
      proxy_reqs
    end

    def proxy_reqs
      proxy_in.on_recv do |message, response|
        log_debug "Proxying #{message.inspect} to htout"
         
        proxy_out.send_message(message) do |http_response|
          log_debug "Received http response #{http_response.inspect} sending back"
          response.send_message(http_response)
        end
      end
    end
  end
end
