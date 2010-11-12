require 'thor'
require 'hudson/core_ext/object/blank'
require 'hudson/core_ext/hash'
require 'hudson/cli/formatting'
require 'hudson/remote'

module Hudson
  class CLI < Thor
    include CLI::Formatting

    map "-v" => :version, "--version" => :version, "-h" => :help, "--help" => :help

    def self.common_options
      method_option :host, :desc => 'connect to hudson server on this host'
      method_option :port, :desc => 'connect to hudson server on this port'
    end

    desc "server [options]", "run a hudson server"
    method_option :home, :desc    => "use this directory to store server data", :type => :string, :default => File.join(ENV['HOME'], ".hudson", "server"), :banner => "PATH"
    method_option :port, :desc    => "run hudson server on this port", :type => :numeric, :default => 3001, :aliases => "-p"
    method_option :control, :desc => "set the shutdown/control port", :type => :numeric, :default => 3002, :aliases => "-c"
    method_option :daemon, :desc  => "fork into background and run as a daemon", :type => :boolean, :default => false
    method_option :kill, :desc    => "send shutdown signal to control port", :type => :boolean, :aliases => "-k"
    method_option :logfile, :desc => "redirect log messages to this file", :type => :string, :banner => "PATH"
    def server
      installation = Hudson::Installation.new(shell, options)
      if options[:kill]
        installation.kill!
        exit(0)
      elsif options[:upgrade]
        installation.upgrade!
        exit(0)
      else
        installation.launch!
      end
    end

    desc "create project_path [options]", "create a build for your project"
    common_options
    method_option :rubies, :desc          => "run tests against multiple explicit rubies via RVM", :type => :string
    method_option :"no-build", :desc      => "create job without initial build", :type => :boolean, :default => false
    method_option :override, :desc        => "override if job exists", :type => :boolean, :default => false
    method_option :"scm", :desc           => "specific SCM URI", :type => :string
    method_option :"scm-branches", :desc  => "list of branches to build from (comma separated)", :type => :string, :default => "master"
    method_option :"public-scm", :desc    => "use public scm URL", :type => :boolean, :default => false
    method_option :"assigned-node", :desc => "only use slave nodes with this label"
    method_option :template, :desc        => "template of job steps (available: #{JobConfigBuilder::VALID_JOB_TEMPLATES.join ','})", :default => 'ruby'
    def create(project_path)
      select_hudson_server(options)
      FileUtils.chdir(project_path) do
        unless scm = Hudson::ProjectScm.discover(options[:scm])
          error "Cannot determine project SCM. Currently supported: #{Hudson::ProjectScm.supported}"
        end
        unless File.exists?("Gemfile")
          error "Ruby/Rails projects without a Gemfile are currently unsupported."
        end
        begin
          template = options[:template]
          job_config = Hudson::JobConfigBuilder.new(template) do |c|
            c.rubies        = options[:rubies].split(/\s*,\s*/) if options[:rubies]
            c.scm           = scm.url
            c.scm_branches  = options[:"scm-branches"].split(/\s*,\s*/)
            c.assigned_node = options[:"assigned-node"] if options[:"assigned-node"]
            c.public_scm    = options[:"public-scm"]
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
    
    desc "job NAME", "Display job details"
    method_option :hash, :desc => 'Dump as formatted Ruby hash format'
    method_option :json, :desc => 'Dump as JSON format'
    method_option :yaml, :desc => 'Dump as YAML format'
    common_options
    def job(name)
      select_hudson_server(options)
      if job = Hudson::Api.job(name)
        if options[:hash]
          require "ap"
          ap job.parsed_response
        elsif options[:json]
          puts job.parsed_response.to_json
        elsif options[:yaml]
          require "yaml"
          puts job.parsed_response.to_yaml
        else
          error "Select an output format: --json, --xml, --yaml, --hash"
        end
      else
        error "Cannot find project '#{name}'."
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
          bold  = color =~ /anime/
          color = 'red' if color =~ /red/
          color = 'green' if color =~ /blue/
          color = 'yellow' if color =~ /grey/ || color == 'disabled'
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
    
    desc "add_node SLAVE_HOST", "add a URI (user@host:port) server as a slave node"
    method_option :label, :desc        => 'Labels for a job --assigned_node to match against to select a slave. Space separated list.'
    method_option :"slave-user", :desc => 'SSH user for Hudson to connect to slave node', :default => "deploy"
    method_option :"slave-port", :desc => 'SSH port for Hudson to connect to slave node', :default => 22
    method_option :"master-key", :desc => 'Location of master public key or identity file'
    method_option :"slave-fs", :desc   => 'Location of file system on slave for Hudson to use'
    method_option :name, :desc         => 'Name of slave node (default SLAVE_HOST)'
    common_options
    def add_node(slave_host)
      select_hudson_server(options)
      if Hudson::Api.add_node({:slave_host => slave_host}.merge(options))
        shell.say "Added slave node #{slave_host}", :green
      else
        error "Failed to add slave node #{slave_host}"
      end
    end

    desc "help [command]", "show help for hudson or for a specific command"
    def help(*args)
      super(*args)
    end

    desc "version", "show version information"
    def version
      shell.say "#{Hudson::VERSION}"
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