require 'java'
require 'tmpdir'

module Jenkins
  def self.rspec_ewwww_gross_hack?
    true
  end
end

require 'jenkins/war'
for path in Dir[File.join(ENV['HOME'], '.jenkins', 'wars', Jenkins::War::VERSION, "**/*.jar")]
  $CLASSPATH << path
end
$CLASSPATH << Pathname(__FILE__).dirname.join('../target/').to_s
$:.unshift Pathname(__FILE__).dirname.join('../lib').to_s

require 'jenkins/plugin/runtime'
require 'jenkins/plugin/proxies/proxy_helper'

def puts(msg = nil)
  require 'erb'
  super ERB::Util.h(msg) + "<br/>"
end

module SpecHelper
  # Java does not support opening directory as a File: File.open(".")
  # So Dir.mktmpdir {} does not work on JRuby because it tries to delete directory
  # with FileUtils.remove_entry_secure which opens a directory as a File.
  def mktmpdir(*a, &b)
    dir = nil
    begin
      dir = Dir.mktmpdir(*a)
      yield dir
    ensure
      # [SECURITY WARNING]
      # We use remove_entry instead of remove_entry_secure.
      # This allows local user to delete arbitrary file and create setuid binary.
      # JRuby should rewrite FileUtils.rm_r in Java.
      #
      # For details of this vulnerability:
      # http://www.cve.mitre.org/cgi-bin/cvename.cgi?name=CAN-2005-0448
      # http://www.cve.mitre.org/cgi-bin/cvename.cgi?name=CAN-2004-0452
      FileUtils.remove_entry(dir, true) if dir
    end
  end
  module_function :mktmpdir

  def create_file(path, content = nil)
    if content.nil? and block_given?
      content = yield
    end
    File.open(path, "wb") do |f|
      f << content
    end
  end
end
