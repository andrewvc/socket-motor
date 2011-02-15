require 'set'

class SocketMotor
  class WSListener
    class WSConnection
      @@connections = {} 
      
      def self.connections; @@connections; end 
      
      def self.find_by_connection_id(connection_id)
        @@connections[connection_id]
      end

      def self.find_by_em_connection(em_conn)
        @@connections[self.connection_id(em_conn)]
      end
      
      def self.connection_id(em_conn)
        "#{SocketMotor.uuid}:#{em_conn.signature}"
      end

      attr_reader :ws_connection, :connection_id, :subscribed_channels
      
      def initialize(connection)
        @ws_connection = connection
        @connection_id = self.class.connection_id(@ws_connection)
        
        # A list of channels this connection is subscribed to
        @subscribed_channels = Set.new
         
        @@connections[connection_id] = self
      end
       
      # teardown, then close the connection
      def close
        teardown
        @ws_connection.close
      end
      
      # Prep the socket for shutdown
      def teardown
        @@connections.delete connection_id
        unsubscribe_all
      end

      # Subscribes the user to the channel with given channel name.
      # If no channel exists the channel is created
      def subscribe(channel_name)
        return nil if subscribed? channel_name
         
        @subscribed_channels << channel_name
        
        WSChannel.find_by_name(channel_name).add_subscriber(self)
      end
      
      # See if the connection is subscribed to +channel_name+
      def subscribed_to?(channel_name)
        @subscribed_channels.include? channel_name
      end

      # Unsubscribe from the given channel name
      def unsubscribe(channel_name)
        return nil unless subscribed? channel_name
        
        WSChannel.find_by_name(channel_name).remove_subscriber(self)
        @subscribed_channels.delete channel_name
      end
      
      # Unsubscribe from all subscribed channels
      def unsubscribe_all
        @subscribed_channels.each do |channel_name|
          unsubscribe channel_name
        end
      end
       
      def subscribed?(channel_name)
        !!@subscribed_channels.include?(channel_name)
      end

      def send_message(message)
        @ws_connection.send_message(message)
      end
    end
  end
end
