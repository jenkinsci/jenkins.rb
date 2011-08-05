
module Jenkins
  module Model

    # Receive/Send events about a running task
    class Listener

      # the underlying hudson.model.TaskListener object
      attr_reader :native

      def initialize(native = nil)
        @native = native
      end

      ##
      # Insert a clickable hyperlink into this tasks's output
      # @param [String] url the link target
      # @param [String] text the link content
      def hyperlink(url, text)
        @native.hyperlink(url, text)
      end

      ##
      # Append a message to the task output.
      # @param [String] msg the message
      def log(msg)
        @native.getLogger().write(msg.to_s)
      end

      ##
      # Append an error message to the task output.
      # @param [String] msg the error message
      def error(msg)
        @native.error(msg.to_s)
      end

      ##
      # Append a fatal error message to the task output
      # @param [String] msg the fatal error message
      def fatal(msg)
        @native.fatalError(msg.to_s)
      end

      Jenkins::Plugins::Proxies.register self, Java.hudson.util.AbstractTaskListener
    end
  end
end