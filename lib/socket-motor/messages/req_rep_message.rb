require 'dripdrop/message'

class SocketMotor
  class ReqRepMessage < DripDrop::Message
    def initialize(name, opts={})
      super
      unless connection_id
        connection_id = opts[:connection_id] || opts['connection_id']
      end
    end

    def sm_head
      head['_sm'] || (head['_sm'] = {})
    end

    def connection_id=(val)
      sm_head['connection_id'] = val
    end
     
    def connection_id
      sm_head['connection_id']
    end
  end
end
