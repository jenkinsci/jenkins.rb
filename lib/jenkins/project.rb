module Jenkins
  class Project
    attr_reader :options
    
    def initialize(options = {})
      @options = options
    end

    def scm
      @scm ||= Scm.discover(options[:scm])
    end

    def path
      @path ||= File.expand_path(options.fetch(:path, FileUtils.pwd))
    end
    
    def name
      @name ||= File.basename(path)
    end
    
    def dir(&blk)
      if block_given?
        FileUtils.chdir(path) do
          yield self
        end
      end
    end
  end
end
