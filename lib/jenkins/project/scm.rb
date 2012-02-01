module Jenkins
  class Project
    class Scm

      class UnsupportedScmError < StandardError; end
      
      def self.discover(scm)
        if File.exist?(".git") && File.directory?(".git")
          ScmGit.new(scm) 
        else
          raise Jenkins::Project::Scm::UnsupportedScmError
        end
      end
      
      def self.supported
        %w[git]
      end
    end

    class ScmGit < Scm
      def initialize(url = nil)
        @url = url
      end
      
      def url
        @url ||= `git config remote.origin.url`.strip
      end
    end
  end
end
