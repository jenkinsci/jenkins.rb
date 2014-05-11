require File.dirname(__FILE__) + "/spec_helper"

describe Jenkins::JobConfigBuilder do
  include ConfigFixtureLoaders

  describe "explicit steps to match a ruby job" do
    before do
      @config = Jenkins::JobConfigBuilder.new(:rails) do |c|
        c.scm = "git://codebasehq.com/mocra/misc/mocra-web.git"
        c.steps = [
          [:build_shell_step, "step 1"],
          [:build_shell_step, "step 2"]
        ]
      end
    end
    it "builds config.xml" do
      steps = Nokogiri.XML(@config.to_xml).search("command")
      expect(steps.map(&:inner_text)).to eq(["step 1", "step 2"])
    end
  end

  describe "rails job; single axis" do
    before do
      @config = Jenkins::JobConfigBuilder.new(:rails) do |c|
        c.scm = "git://codebasehq.com/mocra/misc/mocra-web.git"
      end
    end
    it "builds config.xml" do
      expect(config_xml("rails", "single")).to eq(@config.to_xml)
    end
  end

  describe "many rubies" do
    before do
      @config = Jenkins::JobConfigBuilder.new(:ruby) do |c|
        c.scm = "http://github.com/drnic/picasa_plucker.git"
        c.rubies = %w[1.8.7 1.9.2 rbx-head jruby]
      end
    end
    it "have have explicit rubies" do
      expect(config_xml("ruby", "multi")).to eq(@config.to_xml)
    end

    it "and many labels/assigned_nodes" do
      @config.node_labels = %w[1.8.7 ubuntu]
      expect(config_xml("ruby", "multi-ruby-multi-labels")).to eq(@config.to_xml)
    end
  end

  describe "assigned slave nodes for slave usage" do
    before do
      @config = Jenkins::JobConfigBuilder.new(:rails) do |c|
        c.assigned_node = "my-slave"
      end
    end
    it "builds config.xml" do
      expect(Nokogiri.XML(@config.to_xml).search("assignedNode").size).to eq(1)
      expect(Nokogiri.XML(@config.to_xml).search("assignedNode").text).to eq("my-slave")
      expect(Nokogiri.XML(@config.to_xml).search("canRoam").text).to eq("false")
    end
  end

  describe "no specific slave nodes" do
    before do
      @config = Jenkins::JobConfigBuilder.new(:rails) do |c|
      end
    end
    it "builds config.xml" do
      expect(Nokogiri.XML(@config.to_xml).search("assignedNode").size).to eq(0)
    end
  end

  describe "SCM behaviour" do
    describe "#public_scm = true => convert git@ into git:// until we have deploy keys" do
      before do
        @config = Jenkins::JobConfigBuilder.new(:rails) do |c|
          c.scm = "git@codebasehq.com:mocra/misc/mocra-web.git"
          c.public_scm = true
        end
      end
      it "builds config.xml" do
        expect(config_xml("rails", "single")).to eq(@config.to_xml)
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
        @config = Jenkins::JobConfigBuilder.new(:rails) do |c|
          c.scm = "git@codebasehq.com:mocra/misc/mocra-web.git"
        end
      end
      it "defaults to 'master'" do
        branch_names = Nokogiri.XML(@config.to_xml).search("branches name")
        expect(branch_names.size).to eq(1)
        expect(branch_names.text).to eq("master")
        expect(branch_names.first.parent.name).to eq("hudson.plugins.git.BranchSpec")
      end
      it "can have specific branches" do
        branches = @config.scm_branches = %w[master other branches]
        branch_names = Nokogiri.XML(@config.to_xml).search("branches name")
        expect(branch_names.size).to eq(3)
        expect(branch_names.map(&:inner_text)).to eq(branches)
      end
    end
  end

  describe "setup ENV variables via envfile plugin" do
    before do
      @config = Jenkins::JobConfigBuilder.new(:rails) do |c|
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
      expect(Nokogiri.XML(@config.to_xml).search("buildWrappers").to_s).to eq(xml_bite.strip)
    end
  end

  describe "setup log rotator" do
    before do
      @config = Jenkins::JobConfigBuilder.new(:rails) do |c|
        c.log_rotate = { :days_to_keep => 14 }
      end
    end

    it 'builds config.xml' do
      xml_bite = <<-XML.gsub(/^      /, '')
      <logRotator>
          <daysToKeep>14</daysToKeep>
          <numToKeep>-1</numToKeep>
          <artifactDaysToKeep>-1</artifactDaysToKeep>
          <artifactNumToKeep>-1</artifactNumToKeep>
        </logRotator>
      XML
      expect(Nokogiri.XML(@config.to_xml).search("logRotator").to_s).to eq(xml_bite.strip)
    end
  end

  describe "setup build triggers" do
    before do
      @config = Jenkins::JobConfigBuilder.new(:rails) do |c|
        c.triggers = [{:class => :timer, :spec => "5 * * * *"}]
      end
    end

    it 'builds config.xml' do
      xml_bite = <<-XML.gsub(/^      /, '')
      <triggers class="vector">
          <hudson.triggers.TimerTrigger>
            <spec>5 * * * *</spec>
          </hudson.triggers.TimerTrigger>
        </triggers>
      XML
      expect(Nokogiri.XML(@config.to_xml).search("triggers").to_s).to eq(xml_bite.strip)
    end
  end

  describe "setup publishers for a build" do
    before do
      @config = Jenkins::JobConfigBuilder.new(:none) do |c|
        c.publishers = [
          { :chuck_norris => true },
          { :job_triggers => { :projects => ["Dependent Job", "Even more dependent job"], :on => "FAILURE" } },
          { :mailer       => ["some.guy@example.com", "another.guy@example.com"] }
        ]
      end
    end

    it 'builds config.xml' do
      xml_bite = <<-XML.gsub(/^      /, '')
      <publishers>
          <hudson.plugins.chucknorris.CordellWalkerRecorder>
            <factGenerator/>
          </hudson.plugins.chucknorris.CordellWalkerRecorder>
          <hudson.tasks.BuildTrigger>
            <childProjects>Dependent Job, Even more dependent job</childProjects>
            <threshold>
              <name>FAILURE</name>
              <ordinal>2</ordinal>
              <color>RED</color>
            </threshold>
          </hudson.tasks.BuildTrigger>
          <hudson.tasks.Mailer>
            <recipients>some.guy@example.com, another.guy@example.com</recipients>
            <dontNotifyEveryUnstableBuild>false</dontNotifyEveryUnstableBuild>
            <sendToIndividuals>true</sendToIndividuals>
          </hudson.tasks.Mailer>
        </publishers>
      XML
      expect(Nokogiri.XML(@config.to_xml).search("publishers").to_s).to eq(xml_bite.strip)
    end
  end

  describe "erlang job; single axis" do
    before do
      @config = Jenkins::JobConfigBuilder.new(:erlang) do |c|
        c.scm = "git://codebasehq.com/mocra/misc/mocra-web.git"
      end
    end
    it "builds config.xml" do
      expect(config_xml("erlang", "single")).to eq(@config.to_xml)
    end
  end


end
