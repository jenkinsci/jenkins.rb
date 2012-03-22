module Jenkins::Listeners
  # Receive notification of build events.
  #
  # Include this module in your class in order to receive callbacks
  # when builds are started, completed, deleted, etc...
  #
  # To receive a callback, override the method with the same name as
  # the event. E.g.
  #
  #     class MyRunListener
  #       include Jenkins::Listeners::RunListener
  #
  #       def started(build, listener)
  #         puts "build.inspect started!"
  #       end
  #     end
  #
  module RunListener
    extend Jenkins::Plugin::Behavior
    include Jenkins::Extension

    implemented do |cls|
      Jenkins.plugin.register_extension RunListenerProxy.new(Jenkins.plugin, cls.new)
    end

    # Called when a build is started (i.e. it was in the queue, and will now start running
    # on an executor)
    #
    # @param [Jenkins::Model::Build] the started build
    # @param [Jenkins::Model::TaskListener] the task listener for this build
    def started(build, listener)
    end

    # Called after a build is completed.
    #
    # @param [Jenkins::Model::Build] the completed build
    # @param [Jenkins::Model::TaskListener] the task listener for this build
    def completed(build, listener)
    end

    # Called after a build is finalized.
    #
    # At this point, all the records related to a build is written down to the disk. As such,
    # task Listener is no longer available. This happens later than {#completed}.
    #
    # @param [Jenkins::Model::Build] the finalized build
    def finalized(build)
    end

    # Called right before a build is going to be deleted.
    #
    # @param [Jenkins::Model::Build] The build.
    def deleted(build)
    end
  end
end