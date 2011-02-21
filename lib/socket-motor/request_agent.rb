require 'dripdrop'
require 'ruby-debug' 

trap("INT") {
  $debug = true
}


class SocketMotor
  class RequestAgent < DripDrop::Node::Nodelet
    def configure(opts={})
      @opts     = opts
      @handlers = {}
      @missing_handler = nil
    end

    def action
      requests.on_recv do |message, response|
        puts "MRECV"        

        client_req_id = message.client_req_id
        connection_id = message.connection_id
         
        if    @handlers[message.name]
          resp_message = @handlers[message.name].call(message)
        elsif @handlers[message.class]
          resp_message = @handlers[message.class].call(message)
        else
          resp_message = @missing_handler.call(message) if @missing_handler
        end

        if ! resp_message
          resp_message = SocketMotor::ReqRepMessage.new unless resp_message
        elsif resp_message.is_a?(Hash)
          resp_message = SocketMotor::ReqRepMessage.from_hash(resp_message)
        end

        # Force correct headers for response messages
        resp_message.client_req_id = client_req_id
        resp_message.connection_id = connection_id

        EM::next_tick {
          debugger if $debug == true
          response.send_message(resp_message)
        }
      end
    end

    def handle(name_or_klass,opts={},&block)
      @handlers[name_or_klass] = block
    end

    # Define a handler for all messages not caught by #handle
    def handle_missing(&block)
      @missing_handler = block
    end
  end
end
