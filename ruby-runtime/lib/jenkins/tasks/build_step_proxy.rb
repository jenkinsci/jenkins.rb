module Jenkins
  module Tasks
    module BuildStepProxy
      include Jenkins::Model::DescribableProxy

      def prebuild(build, listener)
        boolean_result(listener) do
          @object.prebuild(import(build), import(listener))
        end
      end

      def perform(build, launcher, listener)
        boolean_result(listener) do
          @object.perform(import(build), import(launcher), import(listener))
        end
      end

    private

    def boolean_result(listener, &block)
      begin
        yield
        true
      rescue Exception => e
        msg = "#{e.message} (#{e.class})\n" << (e.backtrace || []).join("\n")
        listener.error(msg + "\n")
        false
      end
    end
    end
  end
end
