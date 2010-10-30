require 'thor'
require 'hudson/core_ext/object/blank'
require 'hudson/cli/formatting'
require 'hudson/remote'

module Hudson
  class CLI < Thor
    include CLI::Formatting

    map "-v" => :version, "--version" => :version, "-h" => :help, "--help" => :help

    def self.common_options
      method_option :host, :desc => 'connect to hudson server on this host'
      method_option :port, :desc => 'connect to hudson server on this port'
      method_option :server, :desc => 'connect to remote hudson server by search'
    end

    desc "server [options]", "run a hudson server"
    method_option :home, :type => :string, :default => File.join(ENV['HOME'], ".hudson", "server"), :banner => "PATH", :desc => "use this directory to store server data"
    method_option :port, :type => :numeric, :default => 3001, :desc => "run hudson server on this port", :aliases => "-p"
    method_option :control, :type => :numeric, :default => 3002, :desc => "set the shutdown/control port", :aliases => "-c"
    method_option :daemon, :type => :boolean, :default => false, :desc => "fork into background and run as a daemon"
    method_option :kill, :type => :boolean, :desc => "send shutdown signal to control port", :aliases => "-k"
    method_option :logfile, :type => :string, :banner => "PATH", :desc => "redirect log messages to this file"
    def server
      if options[:kill]
        require 'socket'
        TCPSocket.open("localhost", options[:control]) do |sock|
          sock.write("0")
        end
        exit
      end

      serverhome = File.join(options[:home])
      javatmp = File.join(serverhome, "javatmp")
      FileUtils.mkdir_p serverhome
      FileUtils.mkdir_p javatmp
      FileUtils.cp_r Hudson::PLUGINS, serverhome
      ENV['HUDSON_HOME'] = serverhome
      cmd = ["java", "-Djava.io.tmpdir=#{javatmp}", "-jar", Hudson::WAR]
      cmd << "--daemon" if options[:daemon]
      cmd << "--logfile=#{File.expand_path(options[:logfile])}" if options[:logfile]
      cmd << "--httpPort=#{options[:port]}"
      cmd << "--controlPort=#{options[:control]}"
      shell.say cmd.join(" ")
      exec(*cmd)
    end

    desc "create project_path [options]", "create a build for your project"
    common_options
    method_option :"no-build", :desc => "create job without initial build", :type => :boolean, :default => false
    method_option :override, :desc => "override if job exists", :type => :boolean, :default => false
    method_option :assigned_node, :desc => "only use slave nodes with this label"
    method_option :template, :desc => "template of job steps (available: #{JobConfigBuilder::VALID_JOB_TEMPLATES.join ','})", :default => 'ruby'
    def create(project_path)
      select_hudson_server(options)
      FileUtils.chdir(project_path) do
        unless scm = Hudson::ProjectScm.discover
          error "Cannot determine project SCM. Currently supported: #{Hudson::ProjectScm.supported}"
        end
        unless File.exists?("Gemfile")
          error "Ruby/Rails projects without a Gemfile are currently unsupported."
        end
        begin
          template = options[:template]
          job_config = Hudson::JobConfigBuilder.new(template) do |c|
            c.scm = scm.url
            c.assigned_node = options[:assigned_node] if options[:assigned_node]
          end
          name = File.basename(FileUtils.pwd)
          if Hudson::Api.create_job(name, job_config, options)
            build_url = "#{@uri}/job/#{name.gsub(/\s/,'%20')}/build"
            shell.say "Added #{template} project '#{name}' to Hudson.", :green
            unless options[:"no-build"]
              shell.say "Triggering initial build..."
              Hudson::Api.build_job(name)
              shell.say "Trigger additional builds via:"
            else
              shell.say "Trigger builds via:"
            end
            shell.say "  URL: "; shell.say "#{build_url}", :yellow
            shell.say "  CLI: "; shell.say "#{cmd} build #{name}", :yellow
          else
            error "Failed to create project '#{name}'"
          end
        rescue Hudson::JobConfigBuilder::InvalidTemplate
          error "Invalid job template '#{template}'."
        rescue Hudson::Api::JobAlreadyExistsError
          error "Job '#{name}' already exists."
        end
      end
    end
    
    desc "build [PROJECT_PATH]", "trigger build of this project's build job"
    common_options
    def build(project_path = ".")
      select_hudson_server(options)
      FileUtils.chdir(project_path) do
        name = File.basename(FileUtils.pwd)
        if Hudson::Api.build_job(name)
          shell.say "Build for '#{name}' running now..."
        else
          error "No job '#{name}' on server."
        end
      end
    end
    
    desc "remove PROJECT_PATH", "remove this project's build job from Hudson"
    common_options
    def remove(project_path)
      select_hudson_server(options)
      FileUtils.chdir(project_path) do
        name = File.basename(FileUtils.pwd)
        if Hudson::Api.delete_job(name)
          shell.say "Removed project '#{name}' from Hudson."
        else
          error "Failed to delete project '#{name}'."
        end
      end
    end

    desc "list [options]", "list jobs on a hudson server"
    common_options
    def list
      select_hudson_server(options)
      summary = Hudson::Api.summary
      unless summary["jobs"].blank?
        shell.say "#{@uri}:", :bold
        summary["jobs"].each do |job|
          color = job['color']
          color = 'red' if color == 'red_anime'
          color = 'green' if color == 'blue' || color == 'blue_anime'
          color = 'yellow' if color == 'grey' || color == 'disabled'
          bold  = color =~ /anime/
          shell.say "* "; shell.say(shell.set_color(job['name'], color.to_sym, bold), nil, true)
        end
        shell.say ""
      else
        shell.say "#{@uri}: "; shell.say "no jobs", :yellow
      end
    end

    desc "nodes", "list hudson server nodes"
    common_options
    def nodes
      select_hudson_server(options)
      nodes = Hudson::Api.nodes
      nodes["computer"].each do |node|
        color = node["offline"] ? :red : :green
        shell.say node["displayName"], color
      end
    end

    desc "help [command]", "show help for hudson or for a specific command"
    def help(*args)
      super(*args)
    end

    desc "version", "show version information"
    def version
      shell.say "#{Hudson::VERSION} (Hudson Server #{Hudson::HUDSON_VERSION})"
    end

    def self.help(shell, *)
      list = printable_tasks
      shell.say <<-USEAGE
Hudson.rb is a smart set of utilities for making
continuous integration as simple as possible

Usage: hudson command [arguments] [options]

USEAGE

      shell.say "Commands:"
      shell.print_table(list, :ident => 2, :truncate => true)
      shell.say
      class_options_help(shell)
    end

    private

    def select_hudson_server(options)
      unless @uri = Hudson::Api.setup_base_url(options)
        error "Either use --host or add remote servers."
      end
    end

    def display(text)
      shell.say text
      exit
    end

    def error(text)
      shell.say "ERROR: #{text}", :red
      exit
    end
    
    def cmd
      ENV['CUCUMBER_RUNNING'] ? 'hudson' : $0
    end
  end
end