class SocketMotor
  class LogReceiver < DripDrop::Node::Nodelet
    attr_accessor :console_logger

    def run
      @console_logger = Logger.new(STDERR)
      @console_logger.level = Logger::DEBUG
      
      logger_in.on_recv do |message|
        case message.name
        when 'log'
          b = message.body
          formatted = "|#{b['origin_nodelet']}| #{b['message']}"
          @console_logger.send(b['level'],formatted)
        end
      end
    end

    def debug(message); @console_logger.debug message; end
    def info(message);  @console_logger.info  message;  end
    def warn(message);  @console_logger.warn  message; end
    def fatal(message); @console_logger.fatal message; end
  end
end
