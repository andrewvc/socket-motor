require 'dripdrop/message'

class SocketMotor
  class ChannelMessage < DripDrop::Message
    attr_accessor :channel_name
     
    def initialize(name, channel_name)
      super(name)
      @body ||= {}
      @channel_name = channel_name
    end

    def to_hash
      h = super
      h['body'] = {'channel_name' => channel_name}
      h
    end

    class Publish < ChannelMessage
      include DripDrop::SubclassedMessage
       
      attr_accessor :payload
       
      def initialize(channel_name,payload)
        super('publish', channel_name)
        @payload      = payload
      end
      
      def to_hash
        h = super
        h['body'].merge!({'payload' => payload})
        h
      end

      def self.from_hash(h)
        self.new(
          h['body']['channel_name'],
          h['body']['payload']
        )
      end
    end

    class Control < ChannelMessage
      include DripDrop::SubclassedMessage
       
      attr_accessor :operation, :connection_id
       
      def initialize(channel_name,operation,connection_id)
        super('control', channel_name)
        @operation     = operation
        @connection_id = connection_id
      end
      
      def to_hash
        h = super
        h['body'].merge!({'connection_id'  => @connection_id,
                          'operation'      => @operation})
        h
      end

      def self.from_hash(h)
        self.new(
          h['body']['channel_name'],
          h['body']['operation'],
          h['body']['connection_id']
        )
      end
    end
  end
end
