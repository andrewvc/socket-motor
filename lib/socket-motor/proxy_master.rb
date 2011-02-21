class SocketMotor
  class ProxyMaster < DripDrop::Node::Nodelet
    include LogBroadcaster
     
    def run
      proxy_reqs
    end

    def proxy_reqs
      proxy_in.on_recv do |message, response|
        log_debug "Proxying #{message.inspect} to app"
         
        proxy_out.send_message(message) do |app_response|
          log_debug "Received app response #{app_response.inspect} sending back"
          response.send_message(app_response)
        end
      end
    end
  end
end
