
require 'pathname'

module Jenkins
  # Acts as the primary gateway between Ruby and Jenkins
  # There is one instance of this object for the entire
  # plugin
  #
  # On the Java side, it contains a reference to an instance
  # of RubyPlugin. These two objects talk to each other to
  # get things done.
  class Plugin

    # A list of all the hudson.model.Descriptor objects
    # of which this plugin is aware *indexed by Wrapper class*
    #
    # This is used so that wrappers can always have a single place
    # to go when they are asked for a descriptor. That way, wrapper
    # instances can always return the descriptor associated with
    # their class.
    #
    # This may go away.
    attr_reader :descriptors

    # Initializes this plugin by reading the models.rb
    # file. This is a manual registration process
    # Where ruby objects register themselves with the plugin
    # In the future, this process will be automatic, but
    # I haven't decided the best way to do this yet.
    #
    # @param [RubyPlugin] java a native java RubyPlugin
    def initialize(java)
      @java = java
      @start = @stop = proc {}
      @descriptors = {}
      @proxies = Plugins::Proxies.new(self)
      load_models
# KK: needs to figure out how to resurrect this after runtime/plugin split
#      script = 'support/hudson/plugin/models.rb'
#      self.instance_eval @java.read(script), script
    end

    # Called once when Jenkins first initializes this plugin
    # currently does nothing, but plugin startup hooks would
    # go here.
    def start
      @start.call()
    end

    # Called one by Jenkins (via RubyPlugin) when this plugin
    # is shut down. Currently this does nothing, but plugin
    # shutdown hooks would go here.
    def stop
      @stop.call()
    end

    # Reflect an Java object coming from Jenkins into the context of this plugin
    # If the object is originally from the ruby plugin, and it was previously
    # exported, then it will unwrap it. Otherwise, it will just use the object
    # as a normal Java object.
    #
    # @param [Object] object the object to bring in from the outside
    # @return the best representation of that object for this plugin
    def import(object)
      @proxies.import object
    end

    # Reflect a native Ruby object into its External Java form.
    #
    # Delegates to `Plugins::Proxies` for the heavy lifting.
    #
    # @param [Object] object the object
    # @returns [java.lang.Object] the Java proxy
    def export(object)
      @proxies.export object
    end

    def load_models
      puts "Trying to load models from "+@java.getScriptDir().getPath()
      for filename in Dir["#{@java.getScriptDir().getPath()}/models/**/*.rb"]
        puts "Loading "+filename
        load filename
      end
    end
  end
end
