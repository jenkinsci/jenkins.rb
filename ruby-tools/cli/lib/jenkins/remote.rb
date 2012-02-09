module Jenkins
  class Remote
    def self.add_server(name, uri)
      remotes[name] = uri
    end
    
    def self.remotes
      @remotes ||= {}
    end
  end
end