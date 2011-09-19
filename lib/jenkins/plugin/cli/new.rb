
require 'thor/group'

module Jenkins
  class Plugin
    class CLI
      class New < Thor::Group
        include Thor::Actions

        source_root File.dirname(__FILE__)

        argument :name

        def create_gemfile
          template('templates/Gemfile.tt', "#{name}/Gemfile")
        end

        def create_pluginspec
          template('templates/pluginspec.tt', "#{name}/#{name}.pluginspec")
        end

      end
    end
  end
end