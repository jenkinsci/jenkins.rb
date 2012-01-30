require 'core_ext/exception'

module Jenkins::CLI
  # The native Java CLICommand class has a static initializer
  # that prevents the class from being loaded without a running
  # Jenkins instance. This disgusting hack detects if we're in
  # RSpec mode and just creates the proxy class without descending
  # from the Java class.
  if Jenkins.respond_to?(:rspec_ewwww_gross_hack?)
    class CommandProxy; end
  else
    class CommandProxy < Java.hudson.cli.CLICommand; end
  end

  class CommandProxy
    include Jenkins::Plugin::Proxy

    AbortException = Java.hudson.AbortException

    def getShortDescription
      @object.class.description
    end

    def createClone
      self.dup.tap do |dup|
        dup.instance_variable_set(:@object, @object.dup)
      end
    end

    # This mirrors what Java.hudson.cli.CLICommand#getName does, but with the
    # @object's class instead.
    def getName
      @object.class.command_name
    end

    def run
      # We don't call run from within our main, but needs to be here to satisfy the Java Interface
      raise RuntimeError, "This method should never be called."
    end

    # main(List<String> args, Locale locale, InputStream stdin, PrintStream stdout, PrintStream stderr)
    def main(args, locale, stdin, stdout, stderr)
      old_in, old_out, old_err = $stdin, $stdout, $stderr
      begin
        $stdin, $stdout, $stderr = stdin.to_io, stdout.to_io, stderr.to_io
        if @object.parse(args.to_a)
          @object.run
          return 0
        else
          return -1
        end
      rescue AbortException
        return -1
      rescue => e
        $stderr.puts e.full_message
        return -1
      ensure
        $stdin, $stdout, $stderr = old_in, old_out, old_err
      end
    end
  end
end
