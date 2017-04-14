require 'logger'

module Jenkins
  module Model

    # Receive/Send events about a running task
    class Listener

      # the underlying hudson.model.TaskListener object
      attr_reader :native
      attr_accessor :level

      def initialize(native = nil)
        @native = native
        @level = Level::FINE
      end

      def debug?; @level <= FINE;    end
      def info?;  @level <= INFO;    end
      def warn?;  @level <= WARNING; end
      def error?; @level <= SEVERE;  end
      def fatal?; @level <= FATAL;   end

      def debug(msg = nil, &block);   add(Level::FINE,    msg, &block); end
      def info(msg = nil, &block);    add(Level::INFO,    msg, &block); end
      def warn(msg = nil, &block);    add(Level::WARNING, msg, &block); end
      def error(msg = nil, &block);   add(Level::SEVERE,  msg, &block); end
      def fatal(msg = nil, &block);   add(Level::FATAL,   msg, &block); end
      def unknown(msg = nil, &block); add(Level::UNKNOWN, msg, &block); end

      def <<(msg)
        logger.println(msg.to_s)
      end

    private

      def add(severity, msg = nil, &block)
        severity ||= Level::UNKNOWN
        if msg.nil? && block_given?
          msg = yield
        end
        str = msg2str(msg)
        return true if severity < @level
        case severity
        when Level::FINE, Level::INFO
          logger.println(str)
        when Level::WARNING, Level::SEVERE
          @native.error(str + "\n")
        else
          @native.fatalError(str + "\n")
        end
      end

      def msg2str(msg)
        case msg
        when ::String
          msg
        when ::Exception
          "#{msg.message} (#{msg.class})\n" << (msg.backtrace || []).join("\n")
        else
          msg.inspect
        end
      end

      def logger
        @native.getLogger()
      end

      Jenkins::Plugin::Proxies.register self, Java.hudson.util.AbstractTaskListener
    end
  end
end
