require 'jenkins/plugin/tools/bundle'
require 'jenkins/plugin/tools/manifest'
require 'zip/zip'

module Jenkins
  class Plugin
    module Tools
      class Package

        def initialize(target)
          @target = target
        end

        def build
          FileUtils.mkdir_p @target
          spec = Jenkins::Plugin::Specification.find!

          Bundle.new(@target).install

          manifest = Manifest.new(spec)

          file_name = "#{@target}/#{spec.name}.hpi"
          File.delete file_name if File.exists?(file_name)

          Zip::ZipFile.open(file_name, Zip::ZipFile::CREATE) do |zipfile|
            zipfile.get_output_stream("META-INF/MANIFEST.MF") do |f|
              manifest.write_hpi(f)
              f.puts "Bundle-Path: vendor/gems"
            end
            zipfile.mkdir("WEB-INF/classes")

            ["lib","models","views", "#{@target}/vendor"].each do |d|
              Dir.glob("#{d}/**/*") do |f|
                if !File.directory? f
                  p = f.gsub("#{@target}/",'')
                  if p !~ %r{/cache/}
                    zipfile.add("WEB-INF/classes/#{p}",f)
                  end
                end
              end
            end
          end
          puts "#{spec.name} plugin #{spec.version} built to #{file_name}"

        end
      end
    end
  end
end
