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
        @slop = Slop.new
        @run_block = Proc.new {}
        @description = 'No description'
      end
      Jenkins.plugin.register_extension CommandProxy.new(Jenkins.plugin, cls.new)
    end

    module ClassMethods
      attr_reader :slop, :run_block

      def description(desc = nil)
        desc ? @description = desc : @description
      end

      def arguments(&block)
        @slop = Slop.new(&block)
      end

      def run(&run_block)
        @run_block = run_block
      end
    end

    module InstanceMethods
      attr_reader :options

      def parse(args)
        @options = self.class.slop.parse(args)
      rescue InvalidOptionError, MissingOptionError
        $stderr.puts $!.message
        $stderr.puts self.class.description
        $stderr.puts self.class.slop.help
      end

      def run
        self.instance_eval(&self.class.run_block)
      end
    end
  end
end
