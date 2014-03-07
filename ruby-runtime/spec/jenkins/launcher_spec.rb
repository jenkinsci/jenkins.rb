require 'spec_helper'

describe Jenkins::Launcher do
  before :each do
    @native = double("native")
    @starter = double("starter")
    @cmd_proc = double("proc")
    allow(@native).to receive(:launch).and_return(@starter)
    allow(@starter).to receive(:start).and_return(@cmd_proc)
    @launcher = Jenkins::Launcher.new(@native)
  end

  describe "execute" do
    it "passes a simple command to a native launcher" do
      expect(@starter).to receive(:envs).with({})
      expect(@starter).to receive(:cmdAsSingleString).with("ls")
      expect(@cmd_proc).to receive(:join).and_return(0)
      expect(@launcher.execute("ls")).to eq(0)
    end

    describe "environment argument" do
      it "passes env to a native launcher" do
        expect(@starter).to receive(:envs).with({"foo" => "bar"})
        expect(@starter).to receive(:cmdAsSingleString).with("ls")
        expect(@cmd_proc).to receive(:join).and_return(0)
        expect(@launcher.execute({"foo" => "bar"}, "ls")).to eq(0)
      end

      it "stringifies env for a native launcher" do
        expect(@starter).to receive(:envs).with({"foo" => "bar", "baz" => "1"})
        expect(@starter).to receive(:cmdAsSingleString).with("ls")
        expect(@cmd_proc).to receive(:join).and_return(0)
        expect(@launcher.execute({:foo => :bar, :baz => 1}, "ls")).to eq(0)
      end
    end

    describe "option argument" do
      it "passes pwd to a native launcher" do
        expect(@starter).to receive(:envs).with({})
        expect(@starter).to receive(:pwd).with(".")
        expect(@starter).to receive(:cmdAsSingleString).with("ls")
        expect(@cmd_proc).to receive(:join).and_return(0)
        expect(@launcher.execute("ls", :chdir => ".")).to eq(0)
      end

      it "passes an output stream to a native launcher" do
        ous = double("OutputStream")
        expect(ous).to receive(:to_outputstream).and_return(ous)
        expect(@starter).to receive(:envs).with({})
        expect(@starter).to receive(:stdout).with(ous)
        expect(@starter).to receive(:cmdAsSingleString).with("ls")
        expect(@cmd_proc).to receive(:join).and_return(0)
        expect(@launcher.execute("ls", :out => ous)).to eq(0)
      end

      it "passes native listener as an output stream to a native launcher" do
        ous = Jenkins::Model::Listener.new
        plugin = double("Plugin")
        expect(Jenkins::Plugin).to receive(:instance).and_return(plugin)
        expect(plugin).to receive(:export).with(ous).and_return(ous)

        expect(@starter).to receive(:envs).with({})
        expect(@starter).to receive(:stdout).with(ous)
        expect(@starter).to receive(:cmdAsSingleString).with("ls")
        expect(@cmd_proc).to receive(:join).and_return(0)
        expect(@launcher.execute("ls", :out => ous)).to eq(0)
      end

      it "passes an input stream to a native launcher" do
        ins = double("InputStream")
        expect(ins).to receive(:to_inputstream).and_return(ins)
        expect(@starter).to receive(:envs).with({})
        expect(@starter).to receive(:stdin).with(ins)
        expect(@starter).to receive(:cmdAsSingleString).with("ls")
        expect(@cmd_proc).to receive(:join).and_return(0)
        expect(@launcher.execute("ls", :in => ins)).to eq(0)
      end

      it "passes an error stream to a native launcher" do
        ous = double("InputStream")
        expect(ous).to receive(:to_outputstream).and_return(ous)
        expect(@starter).to receive(:envs).with({})
        expect(@starter).to receive(:stderr).with(ous)
        expect(@starter).to receive(:cmdAsSingleString).with("ls")
        expect(@cmd_proc).to receive(:join).and_return(0)
        expect(@launcher.execute("ls", :err => ous)).to eq(0)
      end
    end

    describe "command argument" do
      it "passes a command to a native launcher" do
        expect(@starter).to receive(:envs).with({})
        expect(@starter).to receive(:cmdAsSingleString).with("echo foo bar")
        expect(@cmd_proc).to receive(:join).and_return(0)
        expect(@launcher.execute("echo foo bar")).to eq(0)
      end

      it "passes a stringified command to a native launcher" do
        expect(@starter).to receive(:envs).with({})
        expect(@starter).to receive(:cmdAsSingleString).with("ls")
        expect(@cmd_proc).to receive(:join).and_return(0)
        expect(@launcher.execute(:ls)).to eq(0)
      end

      it "passes a command as Array to a native launcher" do
        expect(@starter).to receive(:envs).with({})
        expect(@starter).to receive(:cmds).with(["echo", "foo", "bar"])
        expect(@cmd_proc).to receive(:join).and_return(0)
        expect(@launcher.execute("echo", "foo", "bar")).to eq(0)
      end
    end

    describe "argument processing" do
      it "passes env, a command and options to a native launcher" do
        ins = double("InputStream")
        expect(ins).to receive(:to_inputstream).and_return(ins)
        ous = double("OutputStream")
        expect(ous).to receive(:to_outputstream).and_return(ous)
        errs = double("ErrorOutputStream")
        expect(errs).to receive(:to_outputstream).and_return(errs)
        expect(@starter).to receive(:envs).with({"FOO" => "BAR"})
        expect(@starter).to receive(:cmds).with(["echo", "hello", "world"])
        expect(@starter).to receive(:stdin).with(ins)
        expect(@starter).to receive(:stdout).with(ous)
        expect(@starter).to receive(:stderr).with(errs)

        expect(@cmd_proc).to receive(:join).and_return(1)
        expect(@launcher.execute({"FOO" => "BAR"}, "echo", "hello", "world", :in => ins, :out => ous, :err => errs)).to eq(1)
      end

      it "converts env with to_hash for passing through" do
        env = double("hashy")
        expect(env).to receive(:to_hash).and_return(:FOO => :BAR)
        expect(@starter).to receive(:envs).with({"FOO" => "BAR"})
        expect(@starter).to receive(:cmds).with(["echo", "hello", "world"])
        expect(@cmd_proc).to receive(:join).and_return(1)
        expect(@launcher.execute(env, "echo", "hello", "world")).to eq(1)
      end

      it "converts options with to_hash for processing" do
        ous = double("OutputStream")
        expect(ous).to receive(:to_outputstream).and_return(ous)
        env = double("hashy env")
        expect(env).to receive(:to_hash).and_return(:FOO => :BAR)
        opt = double("hashy opt")
        expect(opt).to receive(:to_hash).and_return(:chdir => ".", :out => ous)
        expect(@starter).to receive(:envs).with({"FOO" => "BAR"})
        expect(@starter).to receive(:cmds).with(["echo", "hello", "world"])
        expect(@starter).to receive(:pwd).with(".")
        expect(@starter).to receive(:stdout).with(ous)
        expect(@cmd_proc).to receive(:join).and_return(1)
        expect(@launcher.execute(env, "echo", "hello", "world", opt)).to eq(1)
      end
    end
  end

  describe "spawn" do
    it "works like execute without waiting for command execution" do
      ous = double("OutputStream")
      expect(ous).to receive(:to_outputstream).and_return(ous)
      env = double("hashy env")
      expect(env).to receive(:to_hash).and_return(:FOO => :BAR)
      opt = double("hashy opt")
      expect(opt).to receive(:to_hash).and_return(:chdir => ".", :out => ous)
      expect(@starter).to receive(:envs).with({"FOO" => "BAR"})
      expect(@starter).to receive(:cmds).with(["echo", "hello", "world"])
      expect(@starter).to receive(:pwd).with(".")
      expect(@starter).to receive(:stdout).with(ous)
      expect(@cmd_proc).to receive(:join).and_return(2)
      expect(@launcher.spawn(env, "echo", "hello", "world", opt).join).to eq(2)
    end
  end

  describe Jenkins::Launcher::Proc do

    subject { Jenkins::Launcher::Proc.new(@cmd_proc) }

    it "passes an alive? call to a native proc" do
      expect(@cmd_proc).to receive(:isAlive).and_return(true)
      expect(subject.alive?).to eq(true)
    end

    it "passes a join call to a native proc" do
      expect(@cmd_proc).to receive(:join).and_return(0)
      expect(subject.join).to eq(0)
    end

    it "passes a kill call to a native proc" do
      expect(@cmd_proc).to receive(:kill).and_return(:guard)
      expect(subject.kill).to be_nil
    end

    it "passes a stdin call to a native proc" do
      ins = double("InputStream")
      expect(ins).to receive(:to_io).and_return(ins)
      expect(@cmd_proc).to receive(:getStdin).and_return(ins)
      expect(subject.stdin).to eq(ins)
    end

    it "passes a stdout call to a native proc" do
      ous = double("OutputStream")
      expect(ous).to receive(:to_io).and_return(ous)
      expect(@cmd_proc).to receive(:getStdout).and_return(ous)
      expect(subject.stdout).to eq(ous)
    end

    it "passes a stderr call to a native proc" do
      errs = double("OutputStream")
      expect(errs).to receive(:to_io).and_return(errs)
      expect(@cmd_proc).to receive(:getStderr).and_return(errs)
      expect(subject.stderr).to eq(errs)
    end
  end
end
