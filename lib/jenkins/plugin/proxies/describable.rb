module Jenkins
  class Plugin
    class Proxies
      # mix-in on top of the subtypes of the Describable Java class
      # to add standard behaviour as a proxy to Ruby object
      module Describable
        def getDescriptor
          @plugin.descriptors[@object.class]
        end

        def get(name)
          @object.respond_to?(name) ? @object.send(name) : nil
        end
      end
    end
  end
end
