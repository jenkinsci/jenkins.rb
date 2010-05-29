require File.dirname(__FILE__) + "/spec_helper"

describe JobConfigBuilder do
  include ConfigFixtureLoaders
  
  describe "rails job; single axis; block syntax" do
    before do
      @config = JobConfigBuilder.new(:rails) do |c|
        c.scm = "git@codebasehq.com:mocra/misc/mocra-web.git"
        c.git_branches = %w[master]
      end
    end
    it "builds config.xml" do
      config_xml = config_xml("rails", "single")
      config_xml.should == @config.to_xml
    end
  end

  describe "rubygem job; single axis; block syntax" do
    before do
      @config = JobConfigBuilder.new(:rubygem) do |c|
        c.scm = "http://github.com/drnic/picasa_plucker.git"
      end
    end
    it "builds config.xml" do
      config_xml = config_xml("rubygem")
      config_xml.should == @config.to_xml
    end
  end
end