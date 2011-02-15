require 'spec_helper'

describe SocketMotor::WSListener::WSConnection do
  #Shorthand
  WSConn = SocketMotor::WSListener::WSConnection
  WSChan = SocketMotor::WSListener::WSChannel

  
  before do
    @em_connection = mock(:em_connection)
    @em_connection.stub!(:signature).and_return(rand(99*999))
    @connection = WSConn.new @em_connection
  end
  describe "channel subscription life cycle" do
    before do
      @chan_name = 'test'
      @connection.subscribe(@chan_name)
      @chan = WSChan.find_by_name(@chan_name)
    end
    context "when subscribed" do
      it "should create the channel" do
        WSChan.find_by_name(@chan_name).should == @chan
      end
      it "should be marked as subscribed if successful" do
        @connection.subscribed_to?(@chan_name).should be_true
        @chan.subscribers.include?(@connection).should be_true
      end
      it "should create the channel" do
        @chan.should_not be_nil
      end
    end

    context "when unsubscribed" do
      before do
        @connection.unsubscribe(@chan.name)
      end
      it "should be marked as unsubscribed" do
        @connection.subscribed_to?(@chan.name).should be_false
      end
    end

    describe "removing all subscribers" do
      it "should empty the subscriber list" do
        @chan.remove_all_subscribers
        @chan.subscribers.should be_empty
      end
    end

    describe "publishing" do
      before do
        # Add a second subscriber for completeness
        @em_connection2 = mock(:em_connection2)
        @em_connection2.stub!(:signature).and_return rand(99*999)
        @subscribers    = [@connection, WSConn.new(@em_connection2)]
        
        @payload = 'test_payload'
        @message = SocketMotor::ChannelMessage::Publish.new(@chan.name, @payload)

        @chan.remove_all_subscribers
        
        @subscribers.each do |s|
          s.subscribe @chan.name
        end
      end
      it "should start out with the right subscriber list" do
        @chan.subscribers.length.should == 2
        @chan.subscribers.should == Set.new(@subscribers)
      end
      it "should send the published message to all subscribers" do
        @subscribers.each do |s| 
          s.should_receive(:send_message).with(@message)
        end
        @chan.publish(@message)
      end
    end
  end
end
