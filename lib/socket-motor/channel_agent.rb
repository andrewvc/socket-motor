require 'dripdrop'

class SocketMotor
  class ChannelAgent < DripDrop::Node
    def configure(opts={})
      @opts = opts
    end
     
    def action
      route :channel_publish, :http_client, @opts[:channel_address], :message_class => SocketMotor::ReqRepMessage
    end
  end
end
