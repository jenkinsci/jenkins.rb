
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

    # the instance of jenkins.ruby.RubyPlugin with which this Plugin is associated
    attr_reader :peer

    # Initializes this plugin by reading the models.rb
    # file. This is a manual registration process
    # Where ruby objects register themselves with the plugin
    # In the future, this process will be automatic, but
    # I haven't decided the best way to do this yet.
    #
    # @param [org.jenkinsci.ruby.RubyPlugin] java a native java RubyPlugin
    def initialize(java)
      @java = @peer = java
      @start = @stop = proc {}
      @descriptors = {}
      @proxies = Proxies.new(self)
      load_models

       # load model definitions
       # TODO: auto-register them
       self.instance_eval @java.loadBootScript(), "models.rb"
    end

    # unique identifier for this plugin in the Jenkins server
    def name
      @peer.getWrapper().getShortName()
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
    # Delegates to `Proxies` for the heavy lifting.
    #
    # @param [Object] object the object
    # @returns [java.lang.Object] the Java proxy
    def export(object)
      @proxies.export object
    end

    # Link a plugin-local Ruby object to an external Java object.
    #
    # see 'Proxies#link`
    #
    # @param [Object] internal the object on the Ruby side of the link
    # @param [java.lang.Object] external the object on the Java side of the link
    def link(internal, external)
      @proxies.link internal, external
    end

    def load_models
      p = @java.getModelsPath().getPath()
      puts "Trying to load models from #{p}"
      for filename in Dir["#{p}/**/*.rb"]
        puts "Loading "+filename
        load filename
      end
    end
  end
end
