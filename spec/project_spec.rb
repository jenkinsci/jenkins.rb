require 'spec_helper'

module Jenkins
  describe Project do
    let(:project)  { Project.new }
    let(:path)     { double "path" }

    describe "#initialize" do
      let(:some_options) { double "some options" }
      
      it "initializes options attribute" do
        Project.new(some_options).options.should eq some_options
      end
    end
    
    describe "#path" do
      context "when project is initialized with path" do
        let(:expanded_path) { double "expanded path" }

        it "returns the expanded path" do
          File.should_receive(:expand_path).with(path).and_return(expanded_path)
          Project.new(:path => path).path.should eq expanded_path
        end
      end
      
      context "when project is not initialized with path" do
        it "returns current working directory" do
          Project.new.path.should eq FileUtils.pwd
        end
      end
    end

    describe "#scm" do
      let(:scm)        { double "scm" }
      let(:scm_option) { double "scm option" }
      let(:project)    { Project.new(:scm => scm_option) }

      before do
        Project::Scm.stub(:discover => scm)
      end

      it "calls Scm.discover with options[:scm]" do
        Project::Scm.should_receive(:discover).with(scm_option)
        project.scm
      end
      
      it "initializes scm attribute with the result of Scm.discover" do
        project.scm.should eq scm
      end
    end

    describe "#dir" do
      context "when a block is given" do
        it "changes directory to the project path, yields to the block, and resumes to the previous directory" do
          FileUtils.should_receive(:chdir).with(project.path).and_yield
          project.dir { true }
        end
        
        it "yields the project" do
          project.dir do |o|
            o.should eq project
          end
        end
      end
    end
    
    describe "#name" do
      let(:basename) { double "basename" }

      before do
        project.stub(:path => path)
      end
      
      it "retuns the basename of the path" do
        File.should_receive(:basename).with(path).and_return(basename)
        project.name.should eq basename
      end
    end

    class Project
      describe Scm do
        describe ".discover" do
          let(:scm) { double "scm option" }
          let(:git_scm) { double "git scm" }
          
          it "checks whether .git directory exists" do
            File.should_receive(:exist?).with(".git").and_return(true)
            File.should_receive(:directory?).with(".git").and_return(true)
            Scm.discover(scm)
          end

          context "when .git directory does not exist" do
            before do
              File.stub(:exists? => false, :directory? => false)
              ScmGit.stub(:new => git_scm)
            end

            it "raises UnsupportedScmError" do
              lambda { Scm.discover(scm) }.should raise_error(Project::Scm::UnsupportedScmError)
            end
          end
          
          context "when .git directory exists" do
            before do
              File.stub(:exists? => true, :directory? => true)
              ScmGit.stub(:new => git_scm)
            end
            
            it "inititalizes a new Scmgit object with the scm parameter" do
              ScmGit.should_receive(:new).with(scm)
              Scm.discover(scm)
            end

            it "returns the Scmgit object" do
              Scm.discover(scm).should eq git_scm            
            end
          end
        end
      end
    end
  end
end
