module Hudson
  VERSION = "0.2.2"
  HUDSON_VERSION = "1.356"
  WAR = File.expand_path(File.dirname(__FILE__) + "/hudson/hudson.war")
  PLUGINS = File.expand_path(File.dirname(__FILE__) + "/hudson/plugins")
end