module Jenkins::Listeners
  class ItemListenerProxy < Java.hudson.model.listeners.ItemListener
    include Jenkins::Plugin::Proxy

    def initialize(plugin, object)
      super(plugin, object)
    end

    # Called after a new job is created and added to jenkins.model.Jenkins,
    # before the initial configuration page is provided.
    # 
    # This is useful for changing the default initial configuration of newly created jobs.
    # For example, you can enable/add builders, etc.
    def onCreated(item)
      @object.created(import(item))
    end

    # Called after a new job is created by copying from an existing job.
    #
    # For backward compatibility, the default implementation of this method calls onCreated.
    # If you choose to handle this method, think about whether you want to call super.onCopied or not.
    #
    # @param src_item
    #      The source item that the new one was copied from. Never null.
    # @param  item
    #      The newly created item. Never null.
    def onCopied(src_item, item)
      @object.copied(import(src_item), import(item));
    end

    # Called after all the jobs are loaded from disk into jenkins.model.Jenkins
    # object.
    def onLoaded()
      @object.loaded
    end

    # Called right before a job is going to be deleted.
    #
    # At this point the data files of the job is already gone.
    def onDeleted(item)
      @object.deleted(import(item))
    end

    # Called after a job is renamed.
    #
    # @param item
    #      The job being renamed.
    # @param oldName
    #      The old name of the job.
    # @param newName
    #      The new name of the job. Same as Item#getName().
    def onRenamed(item, oldName, newName)
      @object.renamed(import(item), import(oldName), import(newName))
    end

    # Called after a job has its configuration updated.
    #
    # @since 1.460
    def onUpdated(item)
      @object.updated(import(item))
    end

    # Called at the begenning of the orderly shutdown sequence to
    # allow plugins to clean up stuff
    def onBeforeShutdown()
      @object.before_shutdown
    end

  end
end