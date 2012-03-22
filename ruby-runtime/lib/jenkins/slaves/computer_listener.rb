module Jenkins::Slaves
  # Receive notification of what computers in a build array are doing.
  #
  # Include this module in your class in order to receive callbacks
  # when nodes come online, offline, etc.., etc...
  #
  # To receive a callback, override the method with the same name as
  # the event. E.g.
  #
  #     class MyComputerListener
  #       include Jenkins::Slaves::ComputerListener
  #
  #       def online(computer, listener)
  #         puts "#{computer} is now online!"
  #       end
  #     end
  #
  module ComputerListener
    extend Jenkins::Plugin::Behavior
    include Jenkins::Extension

    implemented do |cls|
      Jenkins.plugin.register_extension ComputerListenerProxy.new(Jenkins.plugin, cls.new)
    end

    # Called before a {ComputerLauncher} is asked to launch a connection with {Computer}.
    #
    # This enables you to do some configurable checks to see if we
    # want to bring this slave online or if there are considerations
    # that would keep us from doing so.
    #
    # Calling Computer#abort would let you veto the launch operation. Other thrown exceptions
    # will also have the same effect
    #
    # @param [Jenkins::Model::Computer] computer the computer about to be launched
    # @param [Jenkins::Model::Listener] listener the listener connected to the slave console log.
    def prelaunch(computer, listener)
    end

    # Called when a slave attempted to connect via {ComputerLauncher} but failed.
    #
    # @param [Jenkins::Model::Computer] computer the computer that was trying to launch
    # @param [Jenkins::Model::Listener] listener the listener connected to the slave console log
    def launchfailed(computer, listener)
    end

    # Called before a {Computer} is marked online.
    #
    # This enables you to do some work on all the slaves
    # as they get connected. Unlike {#online},
    # a failure to carry out this function normally will prevent
    # a computer from marked as online.
    #
    # @param [Jenkins::Remote::Channel] channel the channel object to talk to the slave.
    # @param [Jenkins::FilePath] root the directory where this slave stores files.
    # @param [Jenkins::Model::Listener] listener connected to the launch log of the computer.
    # @see {#online}
    def preonline(computer, channel, root, listener)
    end

    # Called right after a {Computer} comes online.
    #
    # This enables you to do some work on all the slaves
    # as they get connected.
    #
    #
    # @param [Jenkins::Model::Computer] computer the computer that just came online
    # @param [Jenkins::Model::Listener] listener connected to the launch log of the computer.
    # @see {#preonline}
    #
    def online(computer, listener)
    end

    # Called right after a {@link Computer} went offline.
    #
    # @param [Jenkins::Model::Computer] computer the computer that just went offline
    def offline(computer)
    end

    # Called when configuration of the node was changed, a node is added/removed, etc.
    def configured()
    end
  end
end