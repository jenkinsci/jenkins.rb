
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
          git_name = %x[git config user.name].chomp
          git_email = %x[git config user.email].chomp

          developer_id = git_email.split('@', 2).first || ''

          # Fallback values.
          git_name = 'TODO: Put your realname here' if git_name.empty?
          git_email = 'email@example.com' if git_email.empty?

          opts = {
            :developer_id => developer_id.empty? ? 'TODO: Put your jenkins-ci.org username here.' : developer_id,
            :developer_name => "#{git_name} <#{git_email}>"
          }

          template('templates/pluginspec.tt', "#{name}/#{name}.pluginspec", opts)
        end

      end
    end
  end
end
