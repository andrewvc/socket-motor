require 'rubygems'
require 'web_socket'
require 'thread'
require 'json'

sem = Mutex.new

Thread.abort_on_exception = true

threads = []
counters = Hash.new(0)
ARGV[0].to_i.times do |i|
  sleep 1 if i % 200 == 0
  print '.'
  $stdout.flush
  threads << Thread.new do
    ws = WebSocket.new('ws://localhost:8080')
    while msg = ws.receive
      print '.'
      ws.send({'name' => 'chat', 'head' => {}, 'body' => 'Lorem Ipsum Sit Dolor Amet'}.to_json)
      counters[i] = 1
    end
    puts 'exiting'
  end
end

Thread.new do 
  while sleep 1
    sem.synchronize {
      puts counters.values.inject(0) {|m,v| m+=v}
      counters = Hash.new(0)
    }
  end
end

threads.each {|t| t.join}
