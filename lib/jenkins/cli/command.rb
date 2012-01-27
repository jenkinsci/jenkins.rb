require 'slop'

module Jenkins::CLI
  # Include this to define a new CLI / SSHD command. Example:
  #
  #   class HelloWorldCommand
  #     include Jenkins::CLI::Command
  #
  #     description "Hello world sample command"
  #
  #     arguments do
  #       on :v, :verbose, 'Print verbosely'
  #       on :n, :name=, 'Set your name, if not Joe', :default => 'Joe'
  #     end
  #
  #     run do
  #       puts "Hello #{options[:name]}!"
  #       if options.verbose?
  #         puts "It's currently #{Time.now}"
  #         puts "Very glad to see you! How are you doing today?"
  #       end
  #     end
  #   end
  #
  module Command
    extend Jenkins::Plugin::Behavior

    implemented do |cls|
      cls.instance_eval do
        @slop_block = Proc.new {}
        @run_block = Proc.new {}
        @description = 'No description'
        command_name default_command_name
      end
      Jenkins.plugin.register_extension CommandProxy.new(Jenkins.plugin, cls.new)
    end

    module ClassMethods
      attr_reader :slop_block, :run_block

      # Set (or get) the description shown by this command in the 'help' CLI
      # command. Also used in the default implementation of Slop's banner -
      # meaning the my-command --help output.
      #
      # Example: description "Cool command that'll rock your world!"
      def description(desc = nil)
        desc ? @description = desc : @description
      end

      # Set up the block passed to Slop.parse. See the Slop README for
      # information on the way this block works:
      # https://github.com/injekt/slop/blob/master/README.md
      #
      # Example: arguments { on :v, :verbose, "Be verbose" }
      def arguments(&slop_block)
        @slop_block = slop_block
      end

      # Set up the block we call when someone runs the CLI command.
      #
      # Example: run { puts "Hello world" }
      def run(&run_block)
        @run_block = run_block
      end

      # This is what the user has to call the command as. The default value is
      # the class name, with any 'Command' suffix removed, and the 'CamelCase'
      # words separated using hypen, into 'camel-case'. This turns
      # HelloWorldCommand into hello-world.
      #
      # Example: command_name "my-cooler-name"
      def command_name(command_name = nil)
        command_name ? @command_name = command_name : @command_name
      end

      # We use this to initialize the default value of @command_name. You can
      # override this using the above `command_name`.
      def default_command_name
        command = name

        # Replace any 'CLICommand' or 'Command' suffix on class name.
        command = command.sub(/(CLI)?Command$/, '')

        # Then convert "FooBarZot" into "Foo-Bar-Zot"
        command = command.gsub(/([a-z0-9])([A-Z])/, '\1-\2')

        # Then lower-case it.
        command.downcase
      end
    end

    module InstanceMethods
      attr_reader :options

      # Sets up the instance based on an array of command-line arguments. The
      # default implementation uses Slop to parse the arguments and passes the
      # block given to Jenkins::CLI::Command::ClassMethods.arguments to figure
      # out the options.
      #
      # You can override this instance method if you don't want to use Slop, or
      # if you want to do some preprocessing before Slop is called.
      def parse(args)
        default_banner = "#{self.class.command_name} [options] - #{self.class.description}"
        @options = Slop.new(:help => true, :strict => true,
                            :banner => default_banner, &self.class.slop_block)
        @options.parse(args)
      rescue Slop::Error => e
        $stderr.puts e.message
        $stderr.puts @options.help
      end

      # Called by the proxy, simply calls the
      # Jenkins::CLI::Command::ClassMethods.run_block. This happens after the
      # Jenkins::CLI::Command::InstanceMethods.parse method has been called.
      #
      # There should generally be no reason to override this. :-)
      def run
        self.instance_eval(&self.class.run_block)
      end
    end
  end
end
