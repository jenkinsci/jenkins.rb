require 'slop'

class Slop
  # Temporary 1.8.x compatibility override, until
  # https://github.com/injekt/slop/pull/50 is in a release.
  def to_s
    heads  = options.reject(&:tail?)
    tails  = (options - heads)
    opts = (heads + tails).select(&:help).map(&:to_s)
    optstr = opts.each_with_index.map { |o, i|
      (str = @separators[i + 1]) ? [o, str].join("\n") : o
    }.join("\n")
    config[:banner] ? config[:banner] + "\n" + optstr : optstr
  end

  alias help to_s
end

module Jenkins::CLI
  module Command
    extend Jenkins::Plugin::Behavior

    implemented do |cls|
      cls.instance_eval do
        @slop_block = Proc.new {}
        @run_block = Proc.new {}
        @description = 'No description'
      end
      Jenkins.plugin.register_extension CommandProxy.new(Jenkins.plugin, cls.new)
    end

    module ClassMethods
      attr_reader :slop_block, :run_block

      def description(desc = nil)
        desc ? @description = desc : @description
      end

      def arguments(&slop_block)
        @slop_block = slop_block
      end

      def run(&run_block)
        @run_block = run_block
      end

      def command_name
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

      def parse(args)
        default_banner = "#{self.class.command_name} [options] - #{self.class.description}"
        @options = Slop.new(:help => true, :strict => true,
                            :banner => default_banner, &self.class.slop_block)
        @options.parse(args)
      rescue Slop::Error => e
        $stderr.puts e.message
        $stderr.puts @options.help
      end

      def run
        self.instance_eval(&self.class.run_block)
      end
    end
  end
end
