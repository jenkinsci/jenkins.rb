require File.dirname(__FILE__) + "/spec_helper"

describe Hudson::JobConfigBuilder do
  include ConfigFixtureLoaders
  
  describe "rails job; single axis; block syntax" do
    before do
      @config = Hudson::JobConfigBuilder.new(:rails) do |c|
        c.scm = "git@codebasehq.com:mocra/misc/mocra-web.git"
        c.git_branches = %w[master]
      end
    end
    it "builds config.xml" do
      config_xml("rails", "single").should == @config.to_xml
    end
  end
  
  describe "rubygem job; single axis; block syntax" do
    before do
      @config = Hudson::JobConfigBuilder.new(:rubygem) do |c|
        c.scm = "http://github.com/drnic/picasa_plucker.git"
      end
    end
    it "builds config.xml" do
      config_xml("rubygem").should == @config.to_xml
    end
  end
  
  describe "assigned slave nodes for slave usage" do
    before do
      @config = Hudson::JobConfigBuilder.new(:rails) do |c|
        c.assigned_node = "my-slave"
      end
    end
    it "builds config.xml" do
      Hpricot.XML(@config.to_xml).search("assignedNode").size.should == 1
      Hpricot.XML(@config.to_xml).search("assignedNode").text.should == "my-slave"
      Hpricot.XML(@config.to_xml).search("canRoam").text.should == "false"
    end
  end
  
  describe "no specific slave nodes" do
    before do
      @config = Hudson::JobConfigBuilder.new(:rails) do |c|
      end
    end
    it "builds config.xml" do
      Hpricot.XML(@config.to_xml).search("assignedNode").size.should == 0
    end
  end
end