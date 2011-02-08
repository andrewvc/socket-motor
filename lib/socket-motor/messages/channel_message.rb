require 'dripdrop/message'

class SocketMotor
  class ChannelMessage < DripDrop::Message
    def self.publish_message(channel_name, message)
      self.new('publish', :body => {'message' => message})
    end
    def self.subscribe_message(channel_name, connection_id)
      self.new('control', :body => {'operation'     => 'subscribe',
                                    'channel_name'  => channel_name,
                                    'connection_id' => connection_id})
    end
    def self.unsubscribe_message(channel_name, connection_id)
      self.new('control', :body => {'operation'     => 'unsubscribe',
                                    'channel_name'  => channel_name,
                                    'connection_id' => connection_id})
    end
    
    def initialize(name, opts={})
      super
      self.channel_name = opts[:channel_name] || opts['channel_name']
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
