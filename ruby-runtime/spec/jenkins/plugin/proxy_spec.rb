require 'spec_helper'

describe "a class with #{Jenkins::Plugin::Proxy} mixed in" do

  before do
    @class = Class.new
    @class.send(:include, Jenkins::Plugin::Proxy)
  end

  it "treats the plugin as transient" do
    expect(@class.transient?(:plugin)).to be_true
  end

  it "leaves other fields alone" do
    expect(@class.transient?(:object)).to be_false
  end

  describe "unmarshalling" do
    before do
      @class.class_eval do
        attr_reader :plugin
      end
      @plugin = double(Jenkins::Plugin)
      @impl = impl = Object.new
      @proxy = @class.allocate
      @proxy.instance_eval do
        @pluginid = "test-plugin"
        @object = impl
      end
      @jenkins = double(Java.jenkins.model.Jenkins)
      @java_plugin = double(:RubyPlugin, :getNativeRubyPlugin => @plugin)
      allow(@jenkins).to receive(:getPlugin).with("test-plugin").and_return(@java_plugin)
      allow(Java.jenkins.model.Jenkins).to receive(:getInstance).and_return(@jenkins)
    end

    it "reconstructs the @plugin field" do
      expect(@plugin).to receive(:linkout).with(@impl, @proxy)
      @proxy.read_completed
      expect(@proxy.plugin).to be(@plugin)
    end
  end

  describe "specifiying which ruby class it proxies" do
    before do
      @proxies = Jenkins::Plugin::Proxies
      allow(@proxies).to receive(:register)
      @class.class_eval do
        proxy_for String
      end
    end

    it 'registers it with the global proxy registry' do
      expect(@proxies).to have_received(:register).with(String, @class)
    end
  end
end
