require 'spec_helper'

module Jenkins
  describe Job do
    let(:job)      { Job.new(:template => template) }
    let(:template) { double "template" }
    let(:config)   { double "config" }
    
    describe "#template" do
      context "when Job is initialized with :template parameter" do
        it "returns the template name" do
          job.template.should eq template
        end
      end
      
      context "when Job is initialized with :no-template parameter" do
        let(:no_template_given_job) { Job.new(:"no-template" => true) }
        
        it "returns 'none'" do
          no_template_given_job.template.should eq "none"
        end
      end
    end

    describe "#config" do
      before do
        job.stub(:template => template)
        Job::ConfigBuilder::VALID_JOB_TEMPLATES.stub(:include? => true)
        Kernel.stub(:open => StringIO.new)
      end
          
      it "checks whether the template is a valid config builder template" do
        Job::ConfigBuilder::VALID_JOB_TEMPLATES.should_receive(:include?).with(template).and_return(false)
        job.config
      end
      
      context "when the template is a valid config builder template" do
        it "returns a new ConfigBuilder initialized with the template" do
          Jenkins::Job::ConfigBuilder.should_receive(:new).with(template).and_return(config)
          job.config.should eq config
        end
      end

      context "when the template is not a valid config builder template" do
        let(:content) { double "content" }
            
        before do
          Job::ConfigBuilder::VALID_JOB_TEMPLATES.stub(:include? => false)
        end
        
        it "returns the content of the file or page given by the template" do
          Kernel.should_receive(:open).with(template).and_return(content)
          content.should_receive(:read).and_return(config)
          job.config.should eq config
        end
      end
    end
  end
end
