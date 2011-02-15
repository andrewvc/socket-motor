require 'spec_helper'

describe SocketMotor::ChannelMessage do
  describe SocketMotor::ChannelMessage::Publish do
    before do
      @chan_name = 'cname'
      @payload   = 'mdata'
      @message = SocketMotor::ChannelMessage::Publish.new(@chan_name,@payload)
    end
    it "should set the channel name properly" do
      @message.channel_name.should == @chan_name
    end

    it "should set the message contents correctly" do
      @message.to_hash['name'].should == 'publish'
      @message.to_hash['body'].should == {'payload' => @payload, 
                                          'channel_name' => @chan_name}
    end
    it "should recreate properly" do
      recreated = SocketMotor::ChannelMessage::Publish.from_hash(@message.to_hash)
      recreated.to_hash.should == @message.to_hash
    end
  end
  describe SocketMotor::ChannelMessage::Control do
    before do
      @chan_name = 'cname'
      @conn_id   = '1291929-12093:1'
    end
    context "subscription" do
      before do
        @sub_message = SocketMotor::ChannelMessage::Control.new(@chan_name,'subscribe',@conn_id)
      end
      it "should set the message contents correctly" do
        @sub_message.to_hash['name'].should == 'control'
        @sub_message.to_hash['body'].should == {'channel_name'  => @chan_name,
                                                'operation'     => 'subscribe',
                                                'connection_id' => @conn_id}
      end
      it "should recreate properly" do
        recreated = SocketMotor::ChannelMessage::Control.from_hash(@sub_message.to_hash)
        recreated.to_hash.should == @sub_message.to_hash
      end
    end
    context "subscription" do
      before do
        @unsub_message = SocketMotor::ChannelMessage::Control.new(@chan_name,'unsubscribe',@conn_id)
      end
      it "should set the message contents correctly" do
        @unsub_message.to_hash['name'].should == 'control'
        @unsub_message.to_hash['body'].should == {'channel_name'  => @chan_name,
                                                  'operation'     => 'unsubscribe',
                                                  'connection_id' => @conn_id}
      end
      it "should recreate properly" do
        recreated = SocketMotor::ChannelMessage::Control.from_hash(@unsub_message.to_hash)
        recreated.to_hash.should == @unsub_message.to_hash
      end
    end
  end
end
