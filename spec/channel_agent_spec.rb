require 'spec_helper'

describe SocketMotor::ChannelAgent do
  before do
    @cagent = SocketMotor::ChannelAgent.new
    @cname  = 'test_cname'
     
    @channel_out = mock("channel_out")
    @cagent.stub!(:channel_out).and_return(@channel_out)
  end
  it "should send publish messages properly" do
    payload = 'test_payload'
    @channel_out.should_receive(:send_message).once.
                with(an_instance_of(SocketMotor::ChannelMessage::Publish))
    @cagent.publish(@cname, payload)
  end
  it "should send subscribe messages properly" do
    connection_id = 'test_conn_id'
    @channel_out.should_receive(:send_message).once.
                with(an_instance_of(SocketMotor::ChannelMessage::Control))
    @cagent.subscribe(@cname, connection_id)
  end
  it "should send unsubscribe messages properly" do
    connection_id = 'test_conn_id'
    @channel_out.should_receive(:send_message).once.
                with(an_instance_of(SocketMotor::ChannelMessage::Control))
    @cagent.unsubscribe(@cname, connection_id)
  end
end
