require 'core_ext/exception'

module Jenkins::CLI
  class CommandProxy < Java.hudson.cli.CLICommand
    include Jenkins::Plugin::Proxy

    def getShortDescription
      @object.description
    end

    def createClone
      self.dup.tap do |dup|
        dup.instance_variable_set(:@object, @object.dup)
      end
    end

    def run
      #we don't call run from within our main, but needs to be here to satisfy the Java Interface
    end

    # main(List<String> args, Locale locale, InputStream stdin, PrintStream stdout, PrintStream stderr)
    def main(args, locale, stdin, stdout, stderr)
      old_in, old_out, old_err = $stdin, $stdout, $stderr
      begin
        $stdin, $stdout, $stderr = stdin, stdout, stderr
        if @object.parse(args)
          @object.run ? 0 : -1
        else
          return -1
        end
      rescue => e
        $stderr.puts e.full_message
        return -1
      ensure
        $stdin, $stdout, $stderr = old_in, old_out, old_err
      end
    end
  end
end
