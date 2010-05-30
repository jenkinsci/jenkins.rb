class ProjectScm
  
  def self.discover
    "git" if File.exist?(".git") && File.directory?(".git")
  end
  def self.supported
    %w[git]
  end
end