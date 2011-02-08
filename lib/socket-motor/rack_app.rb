require 'socket-motor/messages'

Thread.abort_on_exception = true

class SocketMotor
  class RackApp
    @@handlers = {}
    
    def call(env)
      message = SocketMotor::ReqRepMessage.decode_json(env['rack.input'].read)
      
      if @@handlers[message.name]
        response = @@handlers[message.name].call(message)
      else
        response = action(message)
      end
       
      if response.is_a?(Hash)
        response = SocketMotor::ReqRepMessage.from_hash(response)
      elsif !response.is_a?(SocketMotor::ReqRepMessage)
        raise ArgumentError, "Expected a SocketMotor::ReqRepMessage, got #{response.inspect}"
      end

      response.connection_id = message.connection_id
      
      [200, {"Content-Type" => "application/json"}, response.json_encoded]
    end

    # Should be subclassed, for example
    #    def action(message)
    #      conn_id = message.connection_id
    #      {:name => 'hello', :body => "Hello #{conn_id}"}
    #    end
    def action(message)
      
    end

    # Handle messages of a given name
    def self.handle(name,opts={},&block)
      @@handlers[name] = block
    end
  end
end
