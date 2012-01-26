module Jenkins::CLI
  module Command
    extend Jenkins::Plugin::Behavior

    implemented do |cls|
      cls.instance_eval do
        @slop = Slop.new
        @run_block = Proc.new
      end
      Jenkins.plugin.register_extension CommandProxy.new(Jenkins.plugin, cls.new)
    end

    module ClassMethods
      attr_reader :slop, :run_block

      def description(desc = nil)
        desc ? @description = desc : @description
      end

      def parse(&block)
        @slop = Slop.new(&block)
      end

      def run(&run_block)
        @run_block = run_block
      end
    end

    module InstanceMethods
      attr_reader :opts

      def parse(args)
        @opts = self.class.slop.parse(args)
      rescue InvalidOptionError, MissingOptionError
        $stderr.puts $!.message
        $stderr.puts self.class.description
        $stderr.puts self.class.slop.help
      end

      def run
        self.instance_eval(&self.class.run_block) if self.class.run_block
      end
    end
  end
end