module Jenkins
  class Job
    def initialize(options = {})
      @options = options
    end

    def template
      @options[:"no-template"] ? 'none' : @options[:template]
    end

    def config
      Jenkins::Job::ConfigBuilder.new(template) do |c|
        c.rubies        = @options[:rubies].split(/\s*,\s*/) if @options[:rubies]
        c.node_labels   = @options[:"node-labels"].split(/\s*,\s*/) if @options[:"node-labels"]
        c.scm           = @options[:scm].url if @options[:scm]
        c.scm_branches  = @options[:"scm-branches"].split(/\s*,\s*/)
        c.assigned_node = @options[:"assigned-node"] if @options[:"assigned-node"]
        c.public_scm    = @options[:"public-scm"]
      end
    end
  end
end
