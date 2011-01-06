$:.unshift(File.expand_path(File.dirname(__FILE__) + "/../../lib"))
require 'hudson.rb'
require 'bundler/setup'
require 'ap'

Before do
  @tmp_root = File.dirname(__FILE__) + "/../../tmp"
  @home_path = File.expand_path(File.join(@tmp_root, "home"))
  @lib_path  = File.expand_path(File.dirname(__FILE__) + "/../../lib")
  FileUtils.rm_rf   @tmp_root
  FileUtils.mkdir_p @home_path
  ENV['HOME'] = @home_path
  ENV['CUCUMBER_RUNNING'] = 'oooh yes'
end

After do
  ENV.delete('HUDSON_HOST')
  ENV.delete('HUDSON_PORT')
end
