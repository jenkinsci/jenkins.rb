
require 'pathname'

module Jenkins
  # Acts as the primary gateway between Ruby and Jenkins
  # There is one instance of this object for the entire
  # plugin
  #
  # On the Java side, it contains a reference to an instance
  # of RubyPlugin. These two objects talk to each other to
  # get things done.
  #
  # Each running ruby plugin has exactly one instance of
  # `Jenkins::Plugin`
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

    # Add listeners for things that might happen to a plugin. E.g.
    #
    #     plugin.on.start do |plugin|
    #       #do some setup
    #     end
    #     plugin.on.stop do |plugin|
    #       #do some teardown
    #     end
    # @return [Lifecycle]
    attr_reader :on

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
      @on = Lifecycle.new
    end

    # Initialize the singleton instance that will run for a
    # ruby plugin. This method is designed to be called by the
    # Java side when setting up the ruby plugin
    # @return [Jenkins::Plugin] the singleton instance
    def self.initialize(java)
      #TODO: check for double initialization?!?
      @instance = new(java)
      @instance.load_models
      return @instance
    end

    # Get the singleton instance associated with this plugin
    #
    # This is useful when code in the plugin needs to get a
    # reference to the plugin in which it is running e.g.
    #
    #     Jenkins::Plugin.instance #=> the running plugin
    #
    # @return [Jenkins::Plugin] the singleton instance
    def self.instance
      @instance
    end

    # Registers a singleton extension point directly with Jenkins.
    # Extensions registered via this method are different than
    # those registered via `register_describable` in that there
    # are only one instance of them, and so things like configuration
    # construction, and validation do not apply.
    #
    # This method accepts either an instance of the extension point or
    # a class implementing the extension point. If a class is provided,
    # it will attempt to construct an instance with the arguments
    # provided. e.g.
    #     # construct an instance
    #     plugin.register_extension SomeRootAction, "gears.png"
    #     # pass in a preconfigured instance
    #     ext = MyGreatExtension.build do |c|
    #       c.name "fantastic"
    #       c.fizzle :foo
    #     end
    #     plugin.register_extension ext
    #
    # @param [Class|Object] extension the extension to register
    # @param [...] arguments to pass to

    def register_extension(class_or_instance, *args)
      extension = class_or_instance.is_a?(Class) ? class_or_instance.new(*args) : class_or_instance

      # look everywhere for possible ordinal value.
      # extension can be a Java object, or a Proxy to a Ruby object
      ordinal = 0
      if extension.class.respond_to? :order
        ordinal = extension.class.order
      else
        t = import(extension)
        if t.class.respond_to? :order
          ordinal = t.class.order
        end
      end
      @peer.addExtension(export(extension), ordinal)
    end

    # Register a ruby class as a Jenkins extension point of
    # a particular java type
    #
    # This method is invoked automatically as part of the auto-registration
    # process, and should not need to be invoked by plugin code.
    #
    # Classes including `Describabble` will be autoregistered in this way.
    #
    # @param [Class] describable_class the class implementing the extension point
    # @see [Model::Describable]
    def register_describable(describable_class)
      on.start do
        fail "#{describable_class} is not an instance of Describable" unless describable_class < Model::Describable
        descriptor_class = describable_class.descriptor_is
        descriptor = descriptor_class.new(describable_class, self, describable_class.describe_as_type.java_class)
        @descriptors[describable_class] = descriptor
        register_extension(descriptor)
      end
    end

    # unique identifier for this plugin in the Jenkins server
    def name
      @peer.getWrapper().getShortName()
    end

    # Called once when Jenkins first initializes this plugin
    # currently does nothing, but plugin startup hooks would
    # go here.
    def start
      @on.fire(:start, self)
    end

    # Called one by Jenkins (via RubyPlugin) when this plugin
    # is shut down. Currently this does nothing, but plugin
    # shutdown hooks would go here.
    def stop
      @on.fire(:stop, self)
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
    def linkout(internal, external)
      @proxies.linkout internal, external
    end

    # Load all of the Ruby code associated with this plugin. For
    # historical purposes this is called "models", but really
    # it should be something like extensions ext/ or maybe it's
    # just one file associated with the plugin itself. Who knows?
    # The jury is definitely still out on the best way to discover
    # and load extension points.
    def load_models
      path = @java.getModelsPath().getPath()
      # TODO: can we access to Jenkins console logger?
      puts "Trying to load models from #{path}"
      load_file_in_dir(path)
    end

    private

    # Loads files in the specified directory.
    # It seaches directories in depth first with loading files for each directory.
    def load_file_in_dir(dirpath)
      dirs = []
      Dir.new(dirpath).each do |entry|
        next if entry == '.' || entry == '..'
        path = File.join(dirpath, entry)
        if File.directory?(path)
          dirs << path
        elsif /\.rb\z/ =~ path
          puts "Loading " + path
          begin
            load path
          rescue Exception => e
            puts "#{e.message} (#{e.class})\n  " << (e.backtrace || ["(not available)"]).join("\n  ")
          end
          nil
        end
      end
      dirs.each do |dir|
        load_file_in_dir(dir)
      end
    end

    class Lifecycle
      def initialize
        @start = []
        @stop = []
      end

      def start(&block)
        @start << block if block
      end

      def stop(&block)
        @stop << block if block
      end

      def fire(event, *args)
        if listeners = instance_variable_get("@#{event}")
          listeners.each do |l|
            callback(l, *args)
          end
        end
      end
      def callback(listener, *args)
        listener.call(*args)
      rescue Exception => e
        warn "#{e.class}: #{e.message}\n#{e.backtrace.join("\n")}"
      end
    end
  end

  # Make the singleton instance available from the top-level
  # namespace
  #
  #     Jenkins.plugin
  # @see [Jenkins::Plugin.instance]
  def self.plugin
    self::Plugin.instance
  end
end
