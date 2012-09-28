require 'fileutils'

module Jenkins
  module Config
    extend self
    
    def [](key)
      config[key]
    end
    
    def config
      @config ||= if File.exist?(config_file)
        JSON.parse(File.read(config_file))
      else
        {}
      end
    end
    
    def store!
      @config ||= {}
      FileUtils.mkdir_p(File.dirname(config_file))
      File.open(config_file, "w") { |file| file << @config.to_json }
    end
    
    def config_file
      @config_file ||= "#{ENV['HOME']}/.jenkins/jenkinsrb-config.json"
    end
  end
end