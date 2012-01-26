require 'spec_helper'
require 'rspec-spies'

describe "a class with #{Jenkins::Plugin::Proxy} mixed in" do

  before do
    @class = Class.new
    @class.send(:include, Jenkins::Plugin::Proxy)
  end

  it "treats the plugin as transient" do
    @class.transient?(:plugin).should be_true
  end

  it "leaves other fields alone" do
    @class.transient?(:object).should be_false
  end

  describe "unmarshalling" do
    before do
      @class.class_eval do
        attr_reader :plugin
      end
      @plugin = mock(Jenkins::Plugin)
      @impl = impl = Object.new
      @proxy = @class.allocate
      @proxy.instance_eval do
        @pluginid = "test-plugin"
        @object = impl
      end
      @jenkins = mock(Java.jenkins.model.Jenkins)
      @java_plugin = mock(:RubyPlugin, :getNativeRubyPlugin => @plugin)
      @jenkins.stub(:getPlugin).with("test-plugin").and_return(@java_plugin)
      Java.jenkins.model.Jenkins.stub(:getInstance).and_return(@jenkins)
    end

    it "reconstructs the @plugin field" do
      @plugin.should_receive(:linkout).with(@impl, @proxy)
      @proxy.read_completed
      @proxy.plugin.should be(@plugin)
    end
  end

  describe "specifiying which ruby class it proxies" do
    before do
      @proxies = Jenkins::Plugin::Proxies
      @proxies.stub(:register)
      @class.class_eval do
        proxy_for String
      end
    end

    it 'registers it with the global proxy registry' do
      @proxies.should have_received(:register).with(String, @class)
    end
  end
end
