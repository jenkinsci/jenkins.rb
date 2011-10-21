
module Jenkins
  class Plugin
    module Tools
      class Bundle

        def initialize(target)
          @target = target
        end

        def install
          require 'java'
          require 'bundler'
          require 'bundler/cli'
          puts "bundling..."
          ENV['BUNDLE_APP_CONFIG'] = "#{@target}/vendor/bundle"
          Bundler::CLI.start ["--path", "#{@target}/vendor/gems", "--without", "development"]

          generate_standalone([])
        end

        # this code lifted from Bundler::Installer v1.1, so that it will work with 1.0
        def generate_standalone(groups)
         standalone_path = Bundler.settings[:path]
         bundler_path = File.join(standalone_path, "bundler")
         FileUtils.mkdir_p(bundler_path)

         paths = []

         if groups.empty?
           specs = Bundler.definition.requested_specs
         else
           specs = Bundler.definition.specs_for groups.map { |g| g.to_sym }
         end

         specs.each do |spec|
           next if spec.name == "bundler"

           spec.require_paths.each do |path|
             full_path = File.join(spec.full_gem_path, path)
             paths << Pathname.new(full_path).relative_path_from(Bundler.root.join(bundler_path))
           end
         end


         File.open File.join(bundler_path, "setup.rb"), "w" do |file|
           file.puts "path = File.expand_path('..', __FILE__)"
           paths.each do |path|
             file.puts %{$:.unshift File.expand_path("\#{path}/#{path}")}
           end
         end
       end


      end
    end
  end
end