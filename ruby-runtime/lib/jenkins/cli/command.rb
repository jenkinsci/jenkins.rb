require 'slop'

module Jenkins::CLI
  # Extend the Jenkins CLI
  #
  # Jenkins ships with a CLI which can be used to iteract with it
  # from a terminal, or from a program. It also exposes an API with
  # which developers can extend the CLI with their own commands.
  #
  # The Ruby API allows you define a command as a Ruby class, which
  # is then instantiated once for each invocation of the command via
  # the CLI.
  #
  # Argument parsing is flexible, and a parsing scheme (Slop) is
  # provided by default, but this is optional behavior which can
  # be overridden.
  #
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
  # This will create a Jenkins CLI command called `hello-world`
  # Which can be used as
  #     jenkins-cli hello-world --n cowboyd -v
  #
  # @see {https://github.com/injekt/slop Slop}
  # @see {https://wiki.jenkins-ci.org/display/JENKINS/Jenkins+CLI Running Jenkins CLI}
  module Command
    extend Jenkins::Plugin::Behavior
    include Jenkins::Extension

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
      # @param [String] description the description of the command
      # @return [String] the description of the command
      def description(desc = nil)
        desc ? @description = desc : @description
      end

      # Set up the block passed to Slop.parse. See the Slop README for
      # information on the way this block works:
      # https://github.com/injekt/slop/blob/master/README.md
      #
      # Example: arguments { on :v, :verbose, "Be verbose" }
      #
      # @yield a declaration of arguments and options of this command
      def arguments(&slop_block)
        @slop_block = slop_block
      end

      # Define the actual implementation of the command
      #
      # This block specified with {#run} will be invoked in the
      # scope of a fresh instance for each command invocation.
      #
      # Example: run { puts "Hello world" }
      #
      # @yield the command body
      def run(&run_block)
        @run_block = run_block
      end

      # Get/set the name by which the command will be invoked.
      #
      # This is what the user has to call the command as. The default value is
      # the class name, with any 'Command' suffix removed, and the 'CamelCase'
      # words separated using hypen, into 'camel-case'. For example this turns
      # `HelloWorldCommand` into `hello-world`.
      #
      # To use a custom name, just invoke it with that name. E.g.
      #
      #    command_name "my-cooler-name"
      #
      # @param [String] the name with which the command will be invoked
      # @return [String] the command name
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

      # Set up the instance with command-line arguments.
      #
      # Any arguments from the terminal will be passed to {#parse} as
      # a whitespace separated list. The default implementation uses
      # Slop to parse this list with the block passed to {.arguments}
      #
      # Note: If this method returns a falsy value, then the command will
      # *not* be run.
      #
      # You can override this instance method if you don't want to use Slop, or
      # if you want to do some preprocessing before Slop is called.
      # param [Array] args the list of whitespace separated command line arguments
      # return [Object] a truthy value if the parse succeeded and the command can be run.
      def parse(args)
        default_banner = "#{self.class.command_name} [options] - #{self.class.description}"
        @options = Slop.new(:help => true, :strict => true,
                            :banner => default_banner, &self.class.slop_block)
        @options.parse(args)
      rescue Slop::Error => e
        $stderr.puts e.message
        $stderr.puts @options.help
      end

      # Run the command.
      #
      # This method is invoked immediately after {#parse} and
      # implements the "meat" of the command. By default, it invokes
      # body specified with {.run}.
      #
      # There should generally be no reason to override this, but hey
      # it's your world! :-)
      def run
        self.instance_eval(&self.class.run_block)
      end
    end
  end
end
