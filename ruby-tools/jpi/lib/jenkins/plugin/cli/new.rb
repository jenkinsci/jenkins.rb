require 'thor/group'
require 'jenkins/plugin/version'

module Jenkins
  class Plugin
    class CLI
      class New < Thor::Group
        include Thor::Actions

        source_root File.dirname(__FILE__)

        argument :name

        def name
          @name.gsub(/\s+/, '-').sub(/[_-]plugin$/, '')
        end

        def repository_name
          name + '-plugin'
        end

        def create_gemfile
          template('templates/Gemfile.tt', "#{repository_name}/Gemfile")
        end

        def create_pluginspec
          git_name = %x[git config user.name].chomp
          git_email = %x[git config user.email].chomp

          developer_id = git_email.split('@', 2).first || ''

          # Fallback values.
          git_name = 'TODO: Put your realname here' if git_name.empty?
          git_email = 'email@example.com' if git_email.empty?

          display_name_components = repository_name.split(/[-_]/).collect { |w| w.capitalize }

          opts = {
            :developer_id => developer_id.empty? ? 'TODO: Put your jenkins-ci.org username here.' : developer_id,
            :developer_name => "#{git_name} <#{git_email}>",
            :display_name => display_name_components.join(' ')
          }

          template('templates/pluginspec.tt', "#{repository_name}/#{name}.pluginspec", opts)
        end

      end
    end
  end
end
