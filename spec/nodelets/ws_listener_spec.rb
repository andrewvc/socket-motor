require 'spec_helper'

describe SocketMotor::WSListener::WSConnection do
  WSC = SocketMotor::WSListener::WSConnection
  before do
    @em_connection = mock(:em_connection)
    @em_connection.stub!(:signature).and_return(rand(99*999))
    @connection = WSC.new @em_connection
  end
  it "should instantiate a connection" do
    
  end
  describe "channel subscription" do
    before do
      @sid  = @connection.subscribe(:test)
      @chan = WSC.channels_by_name[:test]
    end
    it "should return an sid if successful" do
      @sid.should_not be_nil
    end
    it "should have a channel by that name" do
      @chan.should be_a(EM::Channel)
    end
    it "should be able to receive a message" do
      pending
      @chan << :test_message 
    end
    it "should keep track of the sid" do
      @connection.subscription_sids[:test].should == @sid
    end
  end
  it "should instantiate a connection" do
    WSC.new @em_connection
  end
end
