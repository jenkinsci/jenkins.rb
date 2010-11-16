module Hudson
  class Installation
    attr_reader :directory

    def initialize(shell, opts = {})
      @shell = shell
      @options = opts
      @serverhome = File.expand_path(@options[:home])
      @warfile = File.join(File.dirname(@serverhome), "hudson.war")
      @versionfile = "#{@serverhome}/version.txt"
      @control_port = opts[:control]
    end

    def launch!
      unless warfile?
        @shell.say "no server currently installed."
        upgrade!
      end
      javatmp = File.join(@serverhome, "javatmp")
      FileUtils.mkdir_p javatmp
      ENV['HUDSON_HOME'] = @serverhome
      cmd = ["java", "-Djava.io.tmpdir=#{javatmp}", "-jar", @warfile]
      cmd << "--daemon" if @options[:daemon]
      cmd << "--logfile=#{File.expand_path(@options[:logfile])}" if @options[:logfile]
      cmd << "--httpPort=#{@options[:port]}"
      cmd << "--controlPort=#{@control_port}"
      @shell.say cmd.join(" ")
      exec(*cmd)
    end

    def kill!
      require 'socket'
      TCPSocket.open("localhost", @control_port) do |sock|
        sock.write("0")
      end
      exit
    end

    def upgrade!
      FileUtils.mkdir_p @serverhome
      hudson_stock ? upgrade_from_fixture_stock : upgrade_from_network_stock
    end
    
    def hudson_stock
      ENV['HUDSON_STOCK']
    end

    private

    def warfile?
      File.exists?(@warfile) && system("unzip -l #{@warfile} > /dev/null 2>/dev/null")
    end
    
    def upgrade_from_fixture_stock
      FileUtils.cp File.join(hudson_stock, "hudson.war"), @warfile
      FileUtils.cp_r File.join(hudson_stock, "plugins"), @serverhome
    end

    def upgrade_from_network_stock
      require 'ostruct'
      progress = Progress.new
      latest = progress.means "grabbing the latest metadata from hudson-ci.org" do |step|
        JSON.parse(HTTParty.get("http://hudson-ci.org/update-center.json").lines.to_a[1..-2].join("\n"))
      end
      progress.means "downloading hudson server" do |step|
        latest_version = latest["core"]["version"]
        if latest_version > current_server_version
          puts
          `curl -L --progress-bar #{latest["core"]["url"]} -o #{@warfile}`
          self.current_server_version = latest_version
          step.ok("#{current_server_version} -> #{latest_version}")
        else
          step.ok("Up-to-date at #{current_server_version}")
        end
      end
      
      plugins_dir = File.join(@serverhome, 'plugins')
      plugins = if File.exists?(plugins_dir)
        Dir.chdir(plugins_dir) do
          Dir['*.hpi'].map {|entry| File.basename(entry,".hpi")}
        end
      else
        %w(envfile git github greenballs rake ruby)
      end
      FileUtils.mkdir_p(plugins_dir)
      for plugin in plugins do
        metadata = OpenStruct.new(latest['plugins'][plugin])
        progress.means "downloading #{plugin} plugin" do |step|
          system("curl -L --silent #{metadata.url} > #{plugins_dir}/#{plugin}.hpi")
          step.ok(metadata.version)
        end
      end unless progress.aborted
    end

    def current_server_version
      File.exists?(@versionfile) ? File.read(@versionfile) : "0"
    end
    
    def current_server_version=(version)
      File.open(@versionfile, "w") do |f|
        f.write(version)
      end
    end

    class Progress
      attr_reader :aborted
      def initialize
        @shell = Thor::Shell::Color.new
        @aborted = false
      end

      def means(step)
        return if @aborted
        begin
          @shell.say(step + "... ")
          yield(self).tap do
            @shell.say("[OK]", :green)
          end
        rescue Ok => ok
          @shell.say("[OK#{ok.message ? " - #{ok.message}" : ''}]", :green)
        rescue StandardError => e
          @shell.say("[FAIL - #{e.message}]", :red)
          @aborted = true
          false
        end
      end

      def ok(msg = nil)
        raise Ok.new(msg)
      end
      
      class Ok < StandardError
      end
    end
  end
end
