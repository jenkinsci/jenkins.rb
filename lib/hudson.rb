module Hudson
  WAR            = File.expand_path(File.dirname(__FILE__) + "/hudson/hudson.war")
  PLUGINS        = File.expand_path(File.dirname(__FILE__) + "/hudson/plugins")
end

require 'hudson/version'
require 'hudson/api'
require 'hudson/job_config_builder'
require 'hudson/project_scm'
require 'hudson/installation'
