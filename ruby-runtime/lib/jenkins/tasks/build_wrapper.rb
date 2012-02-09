
require 'jenkins/model'

module Jenkins
  module Tasks
    # Decorate a build with pre and post hooks.
    # {http://javadoc.jenkins-ci.org/hudson/tasks/BuildWrapper.html}
    class BuildWrapper
      include Jenkins::Model
      include Jenkins::Model::Environment
      include Jenkins::Model::Describable
      describe_as Java.hudson.tasks.BuildWrapper
    end
  end
end
