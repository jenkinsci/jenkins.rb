module Jenkins::Slaves
  class ComputerListenerProxy < Java.hudson.slaves.ComputerListener
    include Jenkins::Plugin::Proxy

    def preLaunch(computer, taskListener)
      @object.prelaunch(import(computer), import(listener))
    end

    def onLaunchFailure(computer, taskListener)
      @object.launchfailed(import(computer), import(taskListener))
    end

    def preOnline(computer, channel, rootFilePath, taskListener)
      @object.preonline(import(computer), import(channel), Jenkins::FilePath.new(rootFilePath), import(taskListener))
    end

    def onOnline(computer, listener)
      @object.online(import(computer), import(listener))
    end

    def onOffline(computer)
      @object.offline(import(computer))
    end

    def onConfigurationChange()
      @object.configured()
    end
  end
end
