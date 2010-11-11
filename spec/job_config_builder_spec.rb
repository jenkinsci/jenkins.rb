require File.dirname(__FILE__) + "/spec_helper"

describe Hudson::JobConfigBuilder do
  include ConfigFixtureLoaders
  
  describe "explicit steps to match a ruby job" do
    before do
      @config = Hudson::JobConfigBuilder.new(:rails) do |c|
        c.scm = "git://codebasehq.com/mocra/misc/mocra-web.git"
        c.steps = [
          [:build_shell_step, "step 1"],
          [:build_shell_step, "step 2"]
        ]
      end
    end
    it "builds config.xml" do
      steps = Hpricot.XML(@config.to_xml).search("command")
      steps.map(&:inner_text).should == ["step 1", "step 2"]
    end
  end
  
  
  describe "rails job; single axis" do
    before do
      @config = Hudson::JobConfigBuilder.new(:rails) do |c|
        c.scm = "git://codebasehq.com/mocra/misc/mocra-web.git"
      end
    end
    it "builds config.xml" do
      config_xml("rails", "single").should == @config.to_xml
    end
  end
  
  
  
  describe "ruby job; many rubies" do
    before do
      @config = Hudson::JobConfigBuilder.new(:ruby) do |c|
        c.scm = "http://github.com/drnic/picasa_plucker.git"
        c.rubies = %w[1.8.7 1.9.2 rbx-head jruby]
      end
    end
    it "builds config.xml" do
      config_xml("ruby", "multi").should == @config.to_xml
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
  
  describe "SCM behaviour" do
    describe "#public_scm = true => convert git@ into git:// until we have deploy keys" do
      before do
        @config = Hudson::JobConfigBuilder.new(:rails) do |c|
          c.scm = "git@codebasehq.com:mocra/misc/mocra-web.git"
          c.public_scm = true
        end
      end
      it "builds config.xml" do
        config_xml("rails", "single").should == @config.to_xml
      end
    end
    
    # <branches>
    #   <hudson.plugins.git.BranchSpec>
    #     <name>master</name>
    #   </hudson.plugins.git.BranchSpec>
    #   <hudson.plugins.git.BranchSpec>
    #     <name>other</name>
    #   </hudson.plugins.git.BranchSpec>
    # </branches>
    describe "#scm-branches - set branches" do
      before do
        @config = Hudson::JobConfigBuilder.new(:rails) do |c|
          c.scm = "git@codebasehq.com:mocra/misc/mocra-web.git"
        end
      end
      it "defaults to 'master'" do
        branch_names = Hpricot.XML(@config.to_xml).search("branches name")
        branch_names.size.should == 1
        branch_names.text.should == "master"
        branch_names.first.parent.name.should == "hudson.plugins.git.BranchSpec"
      end
      it "can have specific branches" do
        branches = @config.scm_branches = %w[master other branches]
        branch_names = Hpricot.XML(@config.to_xml).search("branches name")
        branch_names.size.should == 3
        branch_names.map(&:inner_text).should == branches
      end
    end
  end

  describe "setup ENV variables via envfile plugin" do
    before do
      @config = Hudson::JobConfigBuilder.new(:rails) do |c|
        c.scm      = "git://codebasehq.com/mocra/misc/mocra-web.git"
        c.steps    = []
        c.envfile  = "/path/to/env/file"
      end
    end
    it "builds config.xml" do
      xml_bite = <<-XML.gsub(/^      /, '')
      <buildWrappers>
          <hudson.plugins.envfile.EnvFileBuildWrapper>
            <filePath>/path/to/env/file</filePath>
          </hudson.plugins.envfile.EnvFileBuildWrapper>
        </buildWrappers>
      XML
      Hpricot.XML(@config.to_xml).search("buildWrappers").to_s.should == xml_bite.strip
    end
  end
end