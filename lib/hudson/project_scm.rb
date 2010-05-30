module Hudson
  class ProjectScm
  
    def self.discover
      ProjectScmGit.new if File.exist?(".git") && File.directory?(".git")
    end
  
    def self.supported
      %w[git]
    end
  end

  class ProjectScmGit < ProjectScm
    def initialize(url = nil)
      @url = nil
    end
  
    def url
      @url ||= `git config remote.origin.url`.strip
    end
  end
end