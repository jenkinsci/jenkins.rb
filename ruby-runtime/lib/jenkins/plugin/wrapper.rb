class Jenkins::Plugin
  # Proxies provide a lens through which the Java world sees a Ruby
  # object. On the other hand, Wrappers are a lens through which
  # the Ruby world sees a Java object.
  module Wrapper
    extend Behavior

    # The native [java.lang.Object] which this object wraps
    attr_reader :native

    def initialize(*args)
      @native, = *args
    end

    module ClassMethods

      # Declare a wrapper class to wrap a certain type of
      # java class. The plugin runtime will maintain this
      # mapping so that whenever it sees an object coming
      # in from Java, it knows the appropriate wrapper
      # class to choose.
      #
      # @param [java.lang.Class] the java class equivalent
      def wrapper_for(java_class)
        Jenkins::Plugin::Proxies.register self, java_class
      end
    end
  end
end