require 'thor'
require 'jenkins/core_ext/object/blank'
require 'jenkins/core_ext/hash'
require 'jenkins/cli/formatting'
require 'jenkins/remote'

# Until a new version (>= 0.14.6 & 0.15.0rc2) is released, this backports a fix
# for JRuby argument handling:
# https://github.com/wycats/thor/commit/33490a59ed297eb798381f1c86cbaa3608413eaf
class Thor
  class Task
    def sans_backtrace(backtrace, caller) #:nodoc:
      saned  = backtrace.reject { |frame| frame =~ FILE_REGEXP || (frame =~ /\.java:/ && RUBY_PLATFORM =~ /java/) }
      saned -= caller
    end
  end
end


module Jenkins
  class CLI < Thor
    include CLI::Formatting

    map "-v" => :version, "--version" => :version, "-h" => :help, "--help" => :help

    def self.common_options
      method_option :host,     :desc => 'connect to jenkins server on this host'
      method_option :port,     :desc => 'connect to jenkins server on this port'
      method_option :ssl,      :desc => 'connect to jenkins server with ssl', :type => :boolean, :default => false
      method_option :username, :desc => 'connect to jenkins server with username'
      method_option :password, :desc => 'connect to jenkins server with password'
    end

    desc "server [options]", "run a jenkins server"
    method_option :home, :desc    => "use this directory to store server data", :type => :string, :default => File.join(ENV['HOME'], ".jenkins", "server"), :banner => "PATH"
    method_option :port, :desc    => "run jenkins server on this port", :type => :numeric, :default => 3001, :aliases => "-p"
    method_option :control, :desc => "set the shutdown/control port", :type => :numeric, :default => 3002, :aliases => "-c"
    method_option :daemon, :desc  => "fork into background and run as a daemon", :type => :boolean, :default => false
    method_option :kill, :desc    => "send shutdown signal to control port", :type => :boolean, :aliases => "-k"
    method_option :logfile, :desc => "redirect log messages to this file", :type => :string, :banner => "PATH"
    def server
      begin
        require 'jenkins/war'
        Jenkins::War::server(options)
      rescue LoadError
        puts "To run a jenkins server, you need to install the jenkins-war gem. try:"
        puts "gem install jenkins-war"
      end
    end

    desc "create project_path [options]", "create a build for your project"
    common_options
    method_option :rubies, :desc          => "run tests against multiple explicit rubies via RVM", :type => :string
    method_option :"node-labels", :desc   => "run tests against multiple slave nodes by their label (comma separated)"
    method_option :"assigned-node", :desc => "only use slave nodes with this label (similar to --node-labels)"
    method_option :"no-build", :desc      => "create job without initial build", :type => :boolean, :default => false
    method_option :override, :desc        => "override if job exists", :type => :boolean, :default => false
    method_option :"scm", :desc           => "specific SCM URI", :type => :string
    method_option :"scm-branches", :desc  => "list of branches to build from (comma separated)", :type => :string, :default => "master"
    method_option :"public-scm", :desc    => "use public scm URL", :type => :boolean, :default => false
    method_option :template, :desc        => "template of job steps (available: #{JobConfigBuilder::VALID_JOB_TEMPLATES.join ','})", :default => 'ruby'
    method_option :"no-template", :desc   => "do not use a template of default steps; avoids Gemfile requirement", :type => :boolean, :default => false
    def create(project_path)
      select_jenkins_server(options)
      FileUtils.chdir(project_path) do
        scm = discover_scm(options)
        ruby_or_rails_project_without_gemfile?(options)
        begin
          template = options[:"no-template"] ? 'none' : options[:template]
          job_config = build_job_config(scm, template, options)

          if Jenkins::Api.create_job(project_name, job_config, options)
            build_url = "#{@uri}/job/#{project_name.gsub(/\s/,'%20')}/build"
            shell.say "Added#{' ' + template unless template == 'none'} project '#{project_name}' to Jenkins.", :green
            unless options[:"no-build"]
              shell.say "Triggering initial build..."
              Jenkins::Api.build_job(project_name)
              shell.say "Trigger additional builds via:"
            else
              shell.say "Trigger builds via:"
            end
            shell.say "  URL: "; shell.say "#{build_url}", :yellow
            shell.say "  CLI: "; shell.say "#{cmd} build #{project_name}", :yellow
          else
            error "Failed to create project '#{project_name}'"
          end
        rescue Jenkins::JobConfigBuilder::InvalidTemplate
          error "Invalid job template '#{template}'."
        rescue Jenkins::Api::JobAlreadyExistsError
          error "Job '#{project_name}' already exists."
        end
      end
    end

    desc "update project_path [options]", "update the configuration for your project"
    common_options
    method_option :rubies, :desc          => "run tests against multiple explicit rubies via RVM", :type => :string
    method_option :"node-labels", :desc   => "run tests against multiple slave nodes by their label (comma separated)"
    method_option :"assigned-node", :desc => "only use slave nodes with this label (similar to --node-labels)"
    method_option :"no-build", :desc      => "create job without initial build", :type => :boolean, :default => false
    method_option :"scm", :desc           => "specific SCM URI", :type => :string
    method_option :"scm-branches", :desc  => "list of branches to build from (comma separated)", :type => :string, :default => "master"
    method_option :"public-scm", :desc    => "use public scm URL", :type => :boolean, :default => false
    method_option :template, :desc        => "template of job steps (available: #{JobConfigBuilder::VALID_JOB_TEMPLATES.join ','})", :default => 'ruby'
    method_option :"no-template", :desc   => "do not use a template of default steps; avoids Gemfile requirement", :type => :boolean, :default => false
    def update(project_path)
      select_jenkins_server(options)
      FileUtils.chdir(project_path) do
        scm = discover_scm(options)
        ruby_or_rails_project_without_gemfile?(options)
        begin
          template = options[:"no-template"] ? 'none' : options[:template]
          job_config = build_job_config(scm, template, options)

          if Jenkins::Api.update_job(project_name, job_config)
            shell.say "Updated#{' ' + template unless template == 'none'} project '#{project_name}'.", :green
          else
            error "Failed to update project '#{project_name}'"
          end
        rescue Jenkins::JobConfigBuilder::InvalidTemplate
          error "Invalid job template '#{template}'."
        end
      end
    end

    desc "build [PROJECT_PATH]", "trigger build of this project's build job"
    common_options
    def build(project_path = ".")
      select_jenkins_server(options)
      FileUtils.chdir(project_path) do
        if Jenkins::Api.build_job(project_name)
          shell.say "Build for '#{project_name}' running now..."
        else
          error "No job '#{project_name}' on server."
        end
      end
    end

    desc "remove PROJECT_PATH", "remove this project's build job from Jenkins"
    common_options
    def remove(project_path)
      select_jenkins_server(options)
      FileUtils.chdir(project_path) do
        if Jenkins::Api.delete_job(project_name)
          shell.say "Removed project '#{project_name}' from Jenkins."
        else
          error "Failed to delete project '#{project_name}'."
        end
      end
    end

    desc "job NAME", "Display job details"
    method_option :hash, :desc => 'Dump as formatted Ruby hash format'
    method_option :json, :desc => 'Dump as JSON format'
    method_option :yaml, :desc => 'Dump as YAML format'
    common_options
    def job(name)
      select_jenkins_server(options)
      if job = Jenkins::Api.job(name)
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

    desc "build_details JOB_NAME BUILD_NUMBER", "Display details about a particular build"
    method_option :hash, :desc => 'Dump as formatted Ruby hash format'
    method_option :json, :desc => 'Dump as JSON format'
    method_option :yaml, :desc => 'Dump as YAML format'
    common_options
    def build_details(job_name, build_number="lastBuild")
      select_jenkins_server(options)
      if build_details = Jenkins::Api.build_details(job_name, build_number)
        if options[:hash]
          require "ap"
          ap build_details.parsed_response
        elsif options[:json]
          puts build_details.parsed_response.to_json
        elsif options[:yaml]
          require "yaml"
          puts build_details.parsed_response.to_yaml
        else
          error "Select an output format: --json, --yaml, --hash"
        end
      else
        error "Cannot find project '#{job_name}'."
      end
    end

    desc "console JOB_NAME BUILD_NUMBER [AXE]", "Display the console"
    common_options
    def console(job_name, axe=nil, build_number="lastBuild")
      select_jenkins_server(options)
      puts Jenkins::Api.console(job_name, build_number, axe)
    end

    desc "list [options]", "list jobs on a jenkins server"
    common_options
    def list
      select_jenkins_server(options)
      summary = Jenkins::Api.summary
      unless summary["jobs"].blank?
        shell.say "#{@uri}:", :bold
        summary["jobs"].each do |job|
          bold  = job['color'] =~ /anime/
          color = 'red' if job['color'] =~ /red/
          color = 'green' if job['color'] =~ /(blue|green)/
          color ||= 'yellow' # if color =~ /grey/ || color == 'disabled'
          shell.say "* "; shell.say(shell.set_color(job['name'], color.to_sym, bold), nil, true)
        end
        shell.say ""
      else
        shell.say "#{@uri}: "; shell.say "no jobs", :yellow
      end
    end

    desc "nodes", "list jenkins server nodes"
    common_options
    def nodes
      select_jenkins_server(options)
      nodes = Jenkins::Api.nodes
      nodes["computer"].each do |node|
        color = node["offline"] ? :red : :green
        shell.say node["displayName"], color
      end
    end

    desc "add_node SLAVE_HOST", "add a URI (user@host:port) server as a slave node"
    method_option :labels, :desc       => 'Labels for a job --assigned_node to match against to select a slave (comma separated)'
    method_option :"slave-user", :desc => 'SSH user for Jenkins to connect to slave node (default: deploy)'
    method_option :"slave-port", :desc => 'SSH port for Jenkins to connect to slave node (default: 22)'
    method_option :"master-key", :desc => 'Location of master public key or identity file'
    method_option :"slave-fs", :desc   => 'Location of file system on slave for Jenkins to use'
    method_option :name, :desc         => 'Name of slave node (default SLAVE_HOST)'
    method_option :vagrant, :desc      => 'Use settings for a Vagrant VM', :type => :boolean, :default => false
    common_options
    def add_node(slave_host)
      select_jenkins_server(options)
      if results = Jenkins::Api.add_node({:slave_host => slave_host}.merge(options))
        shell.say "Added slave node '#{results[:name]}' to #{results[:slave_host]}", :green
      else
        error "Failed to add slave node #{slave_host}"
      end
    end

    desc "default_host", "display current default host:port URI"
    def default_host
      if select_jenkins_server({})
        display Jenkins::Api.base_uri
      else
        display "No default host yet. Use '--host host --port port' on your first request."
      end
    end

    desc "configure", "configure host connection information"
    common_options
    def configure
      Jenkins::Api.setup_base_url(options)
      Jenkins::Api.cache_configuration!
    end

    desc "auth_info", "display authentication information"
    def auth_info
      if auth = Jenkins::Config.config['basic_auth']
        shell.say "username: #{auth["username"]}"
        shell.say "password: #{auth["password"]}"
      end
    end

    desc "help [command]", "show help for jenkins or for a specific command"
    def help(*args)
      super(*args)
    end

    desc "version", "show version information"
    def version
      shell.say "#{Jenkins::VERSION}"
    end

    def self.help(shell, *)
      list = printable_tasks
      shell.say <<-USEAGE
Jenkins.rb is a smart set of utilities for making
continuous integration as simple as possible

Usage: jenkins command [arguments] [options]

USEAGE

      shell.say "Commands:"
      shell.print_table(list, :ident => 2, :truncate => true)
      shell.say
      class_options_help(shell)
    end

    private

    def method_missing(name, *args)
      console(name, *args)
    end

    def select_jenkins_server(options)
      unless @uri = Jenkins::Api.setup_base_url(options)
        error "Either use --host or add remote servers."
      end
      @uri
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
      ENV['CUCUMBER_RUNNING'] ? 'jenkins' : $0
    end

    def project_name
      @project_name ||= File.basename(FileUtils.pwd)
    end

    def build_job_config(scm, template, options)
      Jenkins::JobConfigBuilder.new(template) do |c|
        c.rubies        = options[:rubies].split(/\s*,\s*/) if options[:rubies]
        c.node_labels   = options[:"node-labels"].split(/\s*,\s*/) if options[:"node-labels"]
        c.scm           = scm.url
        c.scm_branches  = options[:"scm-branches"].split(/\s*,\s*/)
        c.assigned_node = options[:"assigned-node"] if options[:"assigned-node"]
        c.public_scm    = options[:"public-scm"]
      end
    end

    def ruby_or_rails_project_without_gemfile?(options)
      unless (options[:template] == "none" || options[:template] == "erlang" || options[:"no-template"]) || File.exists?("Gemfile")
        error "Ruby/Rails projects without a Gemfile are currently unsupported."
      end
    end

    def discover_scm(options)
      unless scm = Jenkins::ProjectScm.discover(options[:scm])
        error "Cannot determine project SCM. Currently supported: #{Jenkins::ProjectScm.supported}"
      end
      scm
    end
  end
end
