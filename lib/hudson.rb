module Hudson
  VERSION        = "0.2.4"
  HUDSON_VERSION = "1.359"
  WAR            = File.expand_path(File.dirname(__FILE__) + "/hudson/hudson.war")
  PLUGINS        = File.expand_path(File.dirname(__FILE__) + "/hudson/plugins")
end
