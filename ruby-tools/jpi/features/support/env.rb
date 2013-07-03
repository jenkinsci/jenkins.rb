require 'aruba/cucumber'

Before do
  # Default timeout (3 sec) is too short to run JRuby on travis-ci.org
  @aruba_timeout_seconds = 10
end
