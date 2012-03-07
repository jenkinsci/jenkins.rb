module JenkinsHelper
  def test_jenkins_path
    @test_jenkins_path ||= File.expand_path("../../../var/jenkins", __FILE__)
  end
end
World(JenkinsHelper)