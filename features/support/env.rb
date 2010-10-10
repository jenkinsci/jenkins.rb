$:.unshift(File.expand_path(File.dirname(File.dirname(__FILE__) + "/../../lib/hudson.rb")))
require File.dirname(__FILE__) + "/../../lib/hudson.rb"

require 'bundler/setup'

Before do
  @tmp_root = File.dirname(__FILE__) + "/../../tmp"
  @home_path = File.expand_path(File.join(@tmp_root, "home"))
  @lib_path  = File.expand_path(File.dirname(__FILE__) + "/../../lib")
  FileUtils.rm_rf   @tmp_root
  FileUtils.mkdir_p @home_path
  ENV['HOME'] = @home_path
end
