class SocketMotor
  module LogBroadcaster
    # The route logger should be defined in the nodelet this is mixed into
    def log(level, message)
      if message.is_a?(Exception)
        new_message = "Raised #{message.class}: #{message.message}\n"
        new_message << message.backtrace.join("\n")
         
        message = new_message
      end

      logger_broadcast.send_message(
        :name => 'log', 
        :body => {
          :origin_nodelet => self.class.to_s,
          :level => level,
          :message => message})
    end
    
    def log_debug(message); log :debug, message end
    def log_info(message);  log :info,  message end
    def log_warn(message);  log :warn,  message end
    def log_fatal(message); log :fatal, message end
  end
end
