module Hudson
  class Installation
    attr_reader :directory

    def initialize(shell, opts = {})
      @shell = shell
      @options = opts
      @serverhome = @options[:home]
      @warfile = File.join(File.dirname(@serverhome), "hudson.war")
      @control_port = opts[:control]
    end

    def launch!
      upgrade! unless File.exists? @warfile
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
      hudson_stock ? upgrade_from_fixture_stock : upgrade_from_network
    end
    
    def hudson_stock
      ENV['HUDSON_STOCK']
    end
    
    def upgrade_from_fixture_stock
      FileUtils.cp File.join(hudson_stock, "hudson.war"), @warfile
      FileUtils.cp_r File.join(hudson_stock, "plugins"), @serverhome
    end
    
    def upgrade_from_network
      raise "not yet implemented"
    end
  end
end
