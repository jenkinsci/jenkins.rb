require 'java'

require 'jenkins/war'
for path in Dir[File.join(ENV['HOME'], '.jenkins', 'wars', Jenkins::War::VERSION, "**/*.jar")]
  $CLASSPATH << path
end
$CLASSPATH << Pathname(__FILE__).dirname.join('../target')
$:.unshift Pathname(__FILE__).dirname.join('../lib')

require 'jenkins/plugin/runtime'
require 'jenkins/plugins/proxies/proxy_helper'