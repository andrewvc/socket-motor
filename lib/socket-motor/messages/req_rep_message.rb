require 'dripdrop/message'

class SocketMotor
  class ReqRepMessage < DripDrop::Message
    attr_accessor :connection_id, :client_req_id
     
    def initialize(name, opts={})
      super
      @connection_id = opts[:connection_id] || opts['connection_id'] || sm_head['connection_id']
      @client_req_id = opts[:client_req_id] || opts['client_req_id'] || sm_head['client_req_id']
    end

    def sm_head
      head['_sm'] || (head['_sm'] = {})
    end

    def to_hash
      sm_head['connection_id'] = @connection_id
      sm_head['client_req_id'] = @client_req_id
      super
    end

    def self.from_hash(h)
      super
    end

    # For sending secured messages, users can't fake these
    class Internal < SocketMotor::ReqRepMessage; end
  end
end
