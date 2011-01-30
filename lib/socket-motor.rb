require 'dripdrop'
require 'logger'
require 'hashie/mash'

class SocketMotor < DripDrop::Node
  attr_reader :options

  def initialize
    super
    @run_list = :all
    @options  = Hashie::Mash.new
  end
  
  def configure(options={})
    @options.merge! options
  end

  def error_handler(e)
    log_warn(e)
  end

  def action
    route :logger_broadcast, :zmq_publish, options.logger_broadcast, :connect
     
    nodelet :ws_listener, WSListener do |n|
      o = options.nodelets.ws_listener
      n.route :ws_in,        :websocket,     o.ws_in
      n.route :broadcast_in, :zmq_subscribe, o.broadcast_in, :connect
      n.route :channels_in,  :zmq_subscribe, o.channels_in,  :connect
      n.route :proxy_out,    :zmq_xreq,      o.proxy_out,    :connect
    end

    nodelet :broadcast_master, BroadcastMaster do |n|
      o = options.nodelets.broadcast_master
      n.route :broadcast_out, :zmq_publish, o.broadcast_out, :bind
      n.route :broadcast_in,  :http_server, o.broadcast_in
    end   
    
    nodelet :channel_master, ChannelMaster do |n|
      o = options.nodelets.channel_master
      n.route :channels_out, :zmq_publish, o.channels_out, :bind
      n.route :channels_in,  :http_server, o.channels_in
    end

    nodelet :proxy_master, ProxyMaster do |n|
      o = options.nodelets.proxy_master
      n.route :proxy_in,  :zmq_xrep,    o.proxy_in, :bind
      n.route :proxy_out, :http_client, o.proxy_out
    end
  
    nodelet :logger, LogReceiver do |n|
      n.route :logger_in, :zmq_subscribe, options.nodelets.logger.logger_in, :bind
    end
    
    nodelets.each do |name,nlet|
      nlet.run if @run_list == :all || (@run_list.is_a?(Array) && @run_list[name])
    end

    puts "Starting"
  end

  # :stopdoc:
  LIBPATH = ::File.expand_path(::File.dirname(__FILE__)) + ::File::SEPARATOR
  PATH = ::File.dirname(LIBPATH) + ::File::SEPARATOR
  VERSION = ::File.read(PATH + 'version.txt').strip
  # :startdoc:

  # Returns the library path for the module. If any arguments are given,
  # they will be joined to the end of the libray path using
  # <tt>File.join</tt>.
  #
  def self.libpath( *args )
    rv =  args.empty? ? LIBPATH : ::File.join(LIBPATH, args.flatten)
    if block_given?
      begin
        $LOAD_PATH.unshift LIBPATH
        rv = yield
      ensure
        $LOAD_PATH.shift
      end
    end
    return rv
  end

  # Returns the lpath for the module. If any arguments are given,
  # they will be joined to the end of the path using
  # <tt>File.join</tt>.
  #
  def self.path( *args )
    rv = args.empty? ? PATH : ::File.join(PATH, args.flatten)
    if block_given?
      begin
        $LOAD_PATH.unshift PATH
        rv = yield
      ensure
        $LOAD_PATH.shift
      end
    end
    return rv
  end

  # Utility method used to require all files ending in .rb that lie in the
  # directory below this file that has the same name as the filename passed
  # in. Optionally, a specific _directory_ name can be passed in such that
  # the _filename_ does not have to be equivalent to the directory.
  #
  def self.require_all_libs_relative_to( fname, dir = nil )
    dir ||= ::File.basename(fname, '.*')
    search_me = ::File.expand_path(
        ::File.join(::File.dirname(fname), dir, '**', '*.rb'))

    require "#{self.libpath}/socket-motor/log_broadcaster"
    Dir.glob(search_me).sort.each {|rb| require rb}
  end

end  # module SocketMotor

SocketMotor.require_all_libs_relative_to(__FILE__)

#This is ugly
class SocketMotor
  include LogBroadcaster
end
