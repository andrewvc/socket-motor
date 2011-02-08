require 'set'

class SocketMotor
  class WSListener
    class WSConnection
      attr_reader :subscription_sids

      # Map of Connection instances by connection_id
      @@connections = {} 
      # Map of channel names to instances of subscribed WSConnection objects
      @@channels    = Hash.new {|h,k| h[k] = Set.new}
      
      def self.channels; @@channels end
      
      # Creates a channel with no subscribers
      def self.create_channel(channel_name)
        @@channels[channel_name]
      end
      
      # Publishes a message to the named channel
      def self.publish_to_channel(channel_name, message)
        message.head['_sm'] = {}
        message.head['_sm']['channel_name'] = channel_name
        @@channels[channel_name].each do |subscriber|
          puts "SENDING SUB MESSAGE"
          subscriber.connection.send_message message
        end
      end
      
      # Deletes a named channel
      def self.delete_channel(channel_name)
        @@channels[channel_name].each do |subscriber|
          subscriber.unsubscribe channel_name
        end
        @@channels.delete channel_name
      end

      def self.find_by_connection_id(connection_id)
        @@connections[connection_id]
      end

      def self.find_by_em_connection(em_conn)
        @@connections[self.connection_id(em_conn)]
      end
      
      def self.connection_id(em_conn)
        "#{SocketMotor.uuid}:#{em_conn.signature}"
      end
      
      def initialize(connection)
        @connection         = connection
        @subscribed_channels = Set.new
         
        @@connections[connection_id] = self
      end

      def connection_id
        self.class.connection_id(@connection)
      end
       
      def teardown
        # Stop tracking user's connection ID
        @@connections.delete connection_id
        unsubscribe_all
      end

      # Subscribes the user to the channel with given channel name.
      # If no channel exists the channel is created
      def subscribe(channel_name)
        return nil if subscribed? channel_name
         
        @subscribed_channels << channel_name
        @@channels[channel_name] << self
      end

      # Unsubscribe from the given channel name
      def unsubscribe(channel_name)
        return nil unless subscribed? channel_name
         
        @subscribed_channels.delete channel_name
        @@channels[channel_name].delete self
      end
      
      # Unsubscribe from all subscribed channels
      def unsubscribe_all
        @subscribed_channels.each do |channel_name|
          unsubscribe channel_name
        end
      end
       
      def subscribed?(channel_name)
        !!@subscription_sids[channel_name]
      end
    end
  end
end
