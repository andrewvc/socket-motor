require 'dripdrop'

class SocketMotor
  class RequestAgent < DripDrop::Node::Nodelet
    attr_reader   :before_filters
    attr_accessor :message #The current message

   
    def configure(opts={})
      @opts     = opts
      @handlers = {}
      @missing_handler = nil
      @before_filters  = []
    end
     
    def before_filter(&block)
      @before_filters << block
    end
 
    def action
      requests.on_recv do |req_message, response|
        self.message = req_message
         
        client_req_id = message.client_req_id
        connection_id = message.connection_id
        
        before_filters.each { |f| f.call(message) }
         
        if    @handlers[message.name]
          puts "Call #{message.name} #{message.inspect}"
          resp_message = @handlers[message.name].call(message)
        elsif @handlers[message.class]
          resp_message = @handlers[message.class].call(message)
        else
          resp_message = @missing_handler.call(message) if @missing_handler
        end

        
        unless resp_message.is_a?(SocketMotor::ReqRepMessage) || resp_message.is_a?(Hash)
          #raise "Expected a SocketMotor::ReqRepMessage, got '#{resp_message.inspect}' for '#{message.inspect}'"
          resp_message = {:name => 'ack'}
        end

        if ! resp_message
          resp_message = SocketMotor::ReqRepMessage.new unless resp_message
        elsif resp_message.is_a?(Hash)
          resp_message = SocketMotor::ReqRepMessage.from_hash(resp_message)
        end

        # Force correct headers for response messages
        resp_message.client_req_id = client_req_id
        resp_message.connection_id = connection_id

        response.send_message(resp_message)
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
