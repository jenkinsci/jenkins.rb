require 'thor'
require 'hudson/cli/formatting'
require 'active_support/core_ext/object/blank'

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
      puts cmd.join(" ")
      exec(*cmd)
    end

    desc "create [project_path] [options]", "create a continuous build for your project"
    common_options
    method_option :name, :banner => "dir_name", :desc => "name of the build"
    def create(project_path = ".")
      select_hudson_server(options)
      FileUtils.chdir(project_path) do
        unless scm = Hudson::ProjectScm.discover
          error "Cannot determine project SCM. Currently supported: #{Hudson::ProjectScm.supported}"
        end
        job_config = Hudson::JobConfigBuilder.new(:rubygem) do |c|
          c.scm = scm.url
        end
        name = options[:name] || File.basename(FileUtils.pwd)
        if Hudson::Api.create_job(name, job_config)
          build_url = "#{@uri}/job/#{name.gsub(/\s/,'%20')}/build"
          puts "Added project '#{name}' to Hudson."
          puts "Trigger builds via: #{build_url}"
        else
          error "Failed to create project '#{name}'"
        end
      end
    end
    
    desc "list [server] [options]", "list builds on a hudson server"
    common_options
    def list(server = nil)
      select_hudson_server(options)
      if summary = Hudson::Api.summary
        unless summary["jobs"].blank?
          shell.say "#{@uri} -"
          summary["jobs"].each do |job|
            color = job['color']
            color = 'red' if color == 'red_anime'
            color = 'green' if color == 'blue'
            color = 'yellow' if color == 'grey'
            shell.say job['name'], color.to_sym, false
          end
          shell.say ""
        else
          display "#{@uri} - no jobs"
        end
      else
        error "Failed connection to #{@uri}"
      end
    end
    
    desc "add_remote name [options]", "manage remote servers (comming sometime to a theater near you)"
    common_options
    def add_remote(name)
      select_hudson_server(options)
      if Hudson::Remote.add_server(name, options)
        display "Added remote server '#{name}' for #{@uri}"
      else
        error "Could not add remote server for '#{@uri}'"
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

    def self.help(shell)
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
      shell.say "ERROR: #{text}"
      exit
    end
  end
end