require 'dripdrop'

class SocketMotor < DripDrop::Node

  def initialize
    super
    @run_list = :all
  end
  
  def action
    nodelet :ws_listener, WSListener do |n|
      n.route :websocket,    :websocket,     'ws://127.0.0.1:8080'
      n.route :broadcast_in, :zmq_subscribe, 'tcp://127.0.0.1:2200', :connect
      n.route :proxy_out,    :zmq_xreq,      'tcp://127.0.0.1:2201', :connect
    end
    
    nodelet :proxy_master, ProxyMaster do |n|
      n.route :proxy_in,  :zmq_xrep,    'tcp://127.0.0.1:2201', :bind
      n.route :proxy_out, :http_client, 'tcp://127.0.0.1:3000/endpoint'
    end
  
    nodelet :broadcast_master, BroadcastMaster do |n|
      n.route :broadcast_out, :zmq_publish, 'tcp://127.0.0.1:2200', :bind
      n.route :reqs_in,       :zmq_xrep,    'tcp://127.0.0.1:2201', :bind
    end
    
    nodelets.each do |name,nlet|
      nlet.run if @run_list == :all || (@run_list.is_a?(Array) && @run_list[name])
    end
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

    Dir.glob(search_me).sort.each {|rb| require rb}
  end

end  # module SocketMotor

SocketMotor.require_all_libs_relative_to(__FILE__)

