require 'dripdrop/message'

class SocketMotor
  class ChannelMessage < DripDrop::Message
    def initialize(name, opts={})
      self.channel_name = opts[:channel_name] || opts['channel_name']
      super
    end

    def sm_head
      head['_sm'] || (head['_sm'] = {})
    end

    def channel_name=(val)
      sm_head['channel_name'] = val
    end
     
    def channel_name
      sm_head['channel_name']
    end
  end
end
