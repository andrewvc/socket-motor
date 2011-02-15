require 'set'

class SocketMotor
  class WSListener
    class WSChannel
      # Creates missing channels automagically, so be careful with this!
      @@channels    = Hash.new {|h,k| h[k] = WSChannel.new(k)}
      
      # Find a channel with a given name 
      def self.find_by_name(channel_name)
        @@channels[channel_name]
      end
    
      # Creates a new channel with no subscribers
      def self.create_channel(channel_name)
        @@channels[channel_name]
      end
       
      # Unsubscribes all connections from a channel, then deletes it
      def self.delete_channel(channel_name)
        return false unless @@channels[channel_name]
         
        @@channels[channel_name].each do |connection|
          @connection.unsubscribe(channel_name)
        end
        @@channels.delete(channel_name)
      end
      
      attr_reader :name, :subscribers
      
      def initialize(name)
        @name = name
        @subscribers = Set.new
      end

      def add_subscriber(connection)
        @subscribers << connection
      end
      
      def remove_subscriber(connection)
        @subscribers.delete(connection)
      end
      
      def remove_all_subscribers
        @subscribers.each {|s| s.unsubscribe self.name}
      end

      def publish(message)
        @subscribers.each do |subscriber|
          subscriber.send_message(message)
        end
      end
    end
  end
end
