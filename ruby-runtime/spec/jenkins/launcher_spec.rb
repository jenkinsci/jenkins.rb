require 'spec_helper'

describe Jenkins::Launcher do
  before :each do
    @native = mock("native")
    @starter = mock("starter")
    @cmd_proc = mock("proc")
    @native.stub(:launch).and_return(@starter)
    @starter.stub(:start).and_return(@cmd_proc)
    @launcher = Jenkins::Launcher.new(@native)
  end

  describe "execute" do
    it "passes a simple command to a native launcher" do
      @starter.should_receive(:envs).with({})
      @starter.should_receive(:cmdAsSingleString).with("ls")
      @cmd_proc.should_receive(:join).and_return(0)
      @launcher.execute("ls").should == 0
    end

    describe "environment argument" do
      it "passes env to a native launcher" do
        @starter.should_receive(:envs).with({"foo" => "bar"})
        @starter.should_receive(:cmdAsSingleString).with("ls")
        @cmd_proc.should_receive(:join).and_return(0)
        @launcher.execute({"foo" => "bar"}, "ls").should == 0
      end

      it "stringifies env for a native launcher" do
        @starter.should_receive(:envs).with({"foo" => "bar", "baz" => "1"})
        @starter.should_receive(:cmdAsSingleString).with("ls")
        @cmd_proc.should_receive(:join).and_return(0)
        @launcher.execute({:foo => :bar, :baz => 1}, "ls").should == 0
      end
    end

    describe "option argument" do
      it "passes pwd to a native launcher" do
        @starter.should_receive(:envs).with({})
        @starter.should_receive(:pwd).with(".")
        @starter.should_receive(:cmdAsSingleString).with("ls")
        @cmd_proc.should_receive(:join).and_return(0)
        @launcher.execute("ls", :chdir => ".").should == 0
      end

      it "passes an output stream to a native launcher" do
        ous = mock("OutputStream")
        ous.should_receive(:to_outputstream).and_return(ous)
        @starter.should_receive(:envs).with({})
        @starter.should_receive(:stdout).with(ous)
        @starter.should_receive(:cmdAsSingleString).with("ls")
        @cmd_proc.should_receive(:join).and_return(0)
        @launcher.execute("ls", :out => ous).should == 0
      end

      it "passes native listener as an output stream to a native launcher" do
        ous = Jenkins::Model::Listener.new
        plugin = mock("Plugin")
        Jenkins::Plugin.should_receive(:instance).and_return(plugin)
        plugin.should_receive(:export).with(ous).and_return(ous)

        @starter.should_receive(:envs).with({})
        @starter.should_receive(:stdout).with(ous)
        @starter.should_receive(:cmdAsSingleString).with("ls")
        @cmd_proc.should_receive(:join).and_return(0)
        @launcher.execute("ls", :out => ous).should == 0
      end

      it "passes an input stream to a native launcher" do
        ins = mock("InputStream")
        ins.should_receive(:to_inputstream).and_return(ins)
        @starter.should_receive(:envs).with({})
        @starter.should_receive(:stdin).with(ins)
        @starter.should_receive(:cmdAsSingleString).with("ls")
        @cmd_proc.should_receive(:join).and_return(0)
        @launcher.execute("ls", :in => ins).should == 0
      end

      it "passes an error stream to a native launcher" do
        ous = mock("InputStream")
        ous.should_receive(:to_outputstream).and_return(ous)
        @starter.should_receive(:envs).with({})
        @starter.should_receive(:stderr).with(ous)
        @starter.should_receive(:cmdAsSingleString).with("ls")
        @cmd_proc.should_receive(:join).and_return(0)
        @launcher.execute("ls", :err => ous).should == 0
      end
    end

    describe "command argument" do
      it "passes a command to a native launcher" do
        @starter.should_receive(:envs).with({})
        @starter.should_receive(:cmdAsSingleString).with("echo foo bar")
        @cmd_proc.should_receive(:join).and_return(0)
        @launcher.execute("echo foo bar").should == 0
      end

      it "passes a stringified command to a native launcher" do
        @starter.should_receive(:envs).with({})
        @starter.should_receive(:cmdAsSingleString).with("ls")
        @cmd_proc.should_receive(:join).and_return(0)
        @launcher.execute(:ls).should == 0
      end

      it "passes a command as Array to a native launcher" do
        @starter.should_receive(:envs).with({})
        @starter.should_receive(:cmds).with(["echo", "foo", "bar"])
        @cmd_proc.should_receive(:join).and_return(0)
        @launcher.execute("echo", "foo", "bar").should == 0
      end
    end

    describe "argument processing" do
      it "passes env, a command and options to a native launcher" do
        ins = mock("InputStream")
        ins.should_receive(:to_inputstream).and_return(ins)
        ous = mock("OutputStream")
        ous.should_receive(:to_outputstream).and_return(ous)
        errs = mock("ErrorOutputStream")
        errs.should_receive(:to_outputstream).and_return(errs)
        @starter.should_receive(:envs).with({"FOO" => "BAR"})
        @starter.should_receive(:cmds).with(["echo", "hello", "world"])
        @starter.should_receive(:stdin).with(ins)
        @starter.should_receive(:stdout).with(ous)
        @starter.should_receive(:stderr).with(errs)

        @cmd_proc.should_receive(:join).and_return(1)
        @launcher.execute({"FOO" => "BAR"}, "echo", "hello", "world", :in => ins, :out => ous, :err => errs).should == 1
      end

      it "converts env with to_hash for passing through" do
        env = mock("hashy")
        env.should_receive(:to_hash).and_return(:FOO => :BAR)
        @starter.should_receive(:envs).with({"FOO" => "BAR"})
        @starter.should_receive(:cmds).with(["echo", "hello", "world"])
        @cmd_proc.should_receive(:join).and_return(1)
        @launcher.execute(env, "echo", "hello", "world").should == 1
      end

      it "converts options with to_hash for processing" do
        ous = mock("OutputStream")
        ous.should_receive(:to_outputstream).and_return(ous)
        env = mock("hashy env")
        env.should_receive(:to_hash).and_return(:FOO => :BAR)
        opt = mock("hashy opt")
        opt.should_receive(:to_hash).and_return(:chdir => ".", :out => ous)
        @starter.should_receive(:envs).with({"FOO" => "BAR"})
        @starter.should_receive(:cmds).with(["echo", "hello", "world"])
        @starter.should_receive(:pwd).with(".")
        @starter.should_receive(:stdout).with(ous)
        @cmd_proc.should_receive(:join).and_return(1)
        @launcher.execute(env, "echo", "hello", "world", opt).should == 1
      end
    end
  end

  describe "spawn" do
    it "works like execute without waiting for command execution" do
      ous = mock("OutputStream")
      ous.should_receive(:to_outputstream).and_return(ous)
      env = mock("hashy env")
      env.should_receive(:to_hash).and_return(:FOO => :BAR)
      opt = mock("hashy opt")
      opt.should_receive(:to_hash).and_return(:chdir => ".", :out => ous)
      @starter.should_receive(:envs).with({"FOO" => "BAR"})
      @starter.should_receive(:cmds).with(["echo", "hello", "world"])
      @starter.should_receive(:pwd).with(".")
      @starter.should_receive(:stdout).with(ous)
      @cmd_proc.should_receive(:join).and_return(2)
      @launcher.spawn(env, "echo", "hello", "world", opt).join.should == 2
    end
  end

  describe Jenkins::Launcher::Proc do

    subject { Jenkins::Launcher::Proc.new(@cmd_proc) }

    it "passes an alive? call to a native proc" do
      @cmd_proc.should_receive(:isAlive).and_return(true)
      subject.alive?.should == true
    end

    it "passes a join call to a native proc" do
      @cmd_proc.should_receive(:join).and_return(0)
      subject.join.should == 0
    end

    it "passes a kill call to a native proc" do
      @cmd_proc.should_receive(:kill).and_return(:guard)
      subject.kill.should be_nil
    end

    it "passes a stdin call to a native proc" do
      ins = mock("InputStream")
      ins.should_receive(:to_io).and_return(ins)
      @cmd_proc.should_receive(:getStdin).and_return(ins)
      subject.stdin.should == ins
    end

    it "passes a stdout call to a native proc" do
      ous = mock("OutputStream")
      ous.should_receive(:to_io).and_return(ous)
      @cmd_proc.should_receive(:getStdout).and_return(ous)
      subject.stdout.should == ous
    end

    it "passes a stderr call to a native proc" do
      errs = mock("OutputStream")
      errs.should_receive(:to_io).and_return(errs)
      @cmd_proc.should_receive(:getStderr).and_return(errs)
      subject.stderr.should == errs
    end
  end
end
