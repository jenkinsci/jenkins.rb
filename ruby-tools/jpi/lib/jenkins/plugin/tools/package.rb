require 'jenkins/plugin/tools/bundle'
require 'jenkins/plugin/tools/manifest'
require 'zip'

module Jenkins
  class Plugin
    module Tools
      class Package

        def initialize(spec,target)
          @target = target
          @spec = spec
        end

        # where to generate the package?
        def file_name
          file_name = "#{@target}/#{@spec.name}.hpi"
        end

        def build
          FileUtils.mkdir_p @target

          Bundle.new(@target).install

          manifest = Manifest.new(@spec)

          File.delete file_name if File.exists?(file_name)

          Zip::File.open(file_name, Zip::File::CREATE) do |zipfile|
            zipfile.get_output_stream("META-INF/MANIFEST.MF") do |f|
              manifest.write_hpi(f)
              f.puts "Bundle-Path: vendor/gems"
            end
            zipfile.mkdir("WEB-INF/classes")

            ["lib","models","#{@target}/vendor"].each do |d|
              Dir.glob("#{d}/**/*") do |f|
                if !File.directory? f
                  p = f.gsub("#{@target}/",'')
                  if p !~ %r{/cache/}
                    zipfile.add("WEB-INF/classes/#{p}",f)
                  end
                end
              end
            end

            # stapler expects views to be directly in the classpath without any prefix
            Dir.glob("views/**/*") do |f|
              if !File.directory? f
                zipfile.add("WEB-INF/classes/#{f[6..-1]}",f)
              end
            end
          end
          puts "#{@spec.name} plugin #{@spec.version} built to #{file_name}"

        end
      end
    end
  end
end
