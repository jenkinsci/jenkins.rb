module Jenkins
  class Plugin
    module Tools
      class Loadpath
        def initialize(*groups)
          require 'bundler'
          @groups = groups.empty? ? [:default] : groups
        end

        def to_path
          to_a.join(File::PATH_SEPARATOR)
        end

        def to_a
          [].tap do |paths|
            specs = Bundler.definition.specs_for @groups.map {|g| g.to_sym}
            for spec in specs
              next if spec.name == "bundler"
              for path in spec.require_paths
                paths << File.join(spec.full_gem_path, path)
              end
            end
          end
        end

      end
    end
  end
end
