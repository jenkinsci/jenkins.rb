
require 'pathname'

module Jenkins
  class Plugin
    class Specification
      GITHUB_URL_FORMAT = 'git://github.com/%s/%s.git'

      # The name of this plugin. Will be used as a globally
      # unique identifier inside the Jenkins server
      attr_accessor :name

      # The name of this plugin, used for display to end-users.
      # Defaults to name, capitalized.
      attr_writer :display_name

      # Plugin version. This is used during dependency resolution
      attr_accessor :version

      # Free form text description of the plugin. No character limit, but please, keep it civil.
      attr_accessor :description

      # URL to the wiki page of the plugin
      attr_accessor :url

      # A hash of developers, 'id' => 'name <email>' or 'id' => 'name'
      attr_accessor :developers

      # A hash of dependencies, like 'foo' => '1.2.3', 'bar' => '0.0.1'
      # Our dependency handling is not smart (yet).
      attr_accessor :dependencies

      # A hash of :type => [:svn, :git], :url => url to repo
      attr_reader :repository

      def initialize
        @dependencies = {}
        @developers = {}
        yield(self) if block_given?
      end

      # Retrieves the display name of the plugin.
      def display_name
        if @display_name
          @display_name
        else
          self.name.capitalize
        end
      end

      # Adds `plugin_name` as a pre-requisite of
      # this plugin. This can be the name of any Jenkins plugin
      # written in Ruby, Java, or any other language. Version right
      # now must be an *exact* version number.
      def depends_on(plugin_name, version)
        dependencies[plugin_name] = version
      end

      # Adds `id` to the list of developers - this is your jenkins-ci.org
      # account, with the displayed name of `name`. `name` can be "Your Name" or
      # "Your Name <yname@example.com>" if you want to include your e-mail.
      def developed_by(id, name=nil)
        developers[id] = name || id
      end

      # Sets your repository to be `repo`.
      # `repo` is a hash of :type => url
      #  Where :type is one of [:github, :git, :svn]
      #
      # Valid uses:
      #  * uses_repository :github => 'me/my-plugin'
      #  * uses_repository :github => 'my-plugin'
      #  * * Same as :github => 'jenkinsci/my-plugin'.
      #  * uses_repository :git => 'git://repo.or.cz/my-plugin.git'
      #  * uses_repository :svn =>
      #    'https://svn.jenkins-ci.org/trunk/hudson/plugins/my-plugin'
      def uses_repository(repo)
        if @repository or repo.length != 1
          fail SpecificationError , "You can only specify one repository"
        end

        type, url = repo.first
        case type.to_sym
          when :github
            org = 'jenkinsci'
            if url.include?('/')
              org, url = url.split('/', 2)
            end

            url = GITHUB_URL_FORMAT % [org, url]
            @repository = {:type => :git, :url => url}.freeze
          when :git, :svn
            @repository = {:type => type.to_sym, :url => url}.freeze
        end
      end

      # Make sure that your specification is not corrupt.
      def validate!
        [:name, :version, :description].each do |field|
          fail SpecificationError, "field may not be nil" unless send(field)
        end
      end

      # Evaluates `path` as ruby code, expecting it to contain an instance
      # of `Jenkins::Plugin::Specification`.
      #
      # @return [Jenkins::Plugin::Specification] the loaded specification
      def self.load(path)
        _path = path.to_s
        eval(File.read(_path), binding, _path, 1)
      end

      # Looks inside `dir` for a file ending in .pluginspec, and if found,
      # loads it.
      #
      # @return [Jenkins::Plugin::Specification] the loaded specification object, nil otherwise
      def self.find(dir = Dir.pwd)
        dir = Pathname(dir)
        if spec_path = Pathname(dir).entries.find {|e| e.to_s =~ /\.pluginspec$/}
          load(dir.join(spec_path).to_s)
        end
      rescue Errno::ENOENT => e
        fail SpecificationNotFound, "#{dir} does not appear to be a directory"
      end

      # Attempts to `#find` a plugin spec in `dir` and raises an exception if unsuccessful
      #
      # @param [String] path in which to look
      # @return [Jenkins::Plugin::Specification] the found specifiaction object
      def self.find!(dir = Dir.pwd)
        find(dir) or fail SpecificationNotFound, "no plugin specification found in #{dir}"
      end
    end

    SpecificationError = Class.new(StandardError)
    SpecificationNotFound = Class.new(SpecificationError)
  end
end
