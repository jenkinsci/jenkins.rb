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
      context "when template is a URI" do
      end

      context "when template is a file" do
      end

      context "when template is not a file or URI" do
        before do
          job.stub(:template => template)
        end
        
        it "returns a new ConfigBuilder initialized with the template" do
          Jenkins::Job::ConfigBuilder.should_receive(:new).with(template).and_return(config)
          job.config.should eq config
        end
      end
    end
  end
end
