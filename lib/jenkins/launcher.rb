
module Jenkins

  # Launch processes on build slaves. No functionality is currently exposed
  class Launcher
    # the nantive hudson.Launcher object
    attr_reader :native

    def initialize(native = nil)
      @native = native
    end

    # TODO: wrap needed.
    # Do we really wrap whole Launcher.ProcStarter things?
    # Or create our own Launcher (must support remote, local, etc)
    def launch
      @native.launch()
    end

    Plugin::Proxies.register self, Java.hudson.Launcher
  end
end
