require 'thor'
require 'ostruct'
require 'json'
require 'hudson'
class Hudson::Progress
  
  def initialize
    @shell = Thor::Shell::Color.new
  end
  
  def means(step)
    begin
      @shell.say(step + "... ")
      yield(self).tap do
        @shell.say("[OK]", :green)
      end
    rescue Ok => ok
      @shell.say("[OK#{ok.message ? " - #{ok.message}" : ''}]", :green)
    rescue StandardError => e
      @shell.say("[FAIL - #{e.message}]", :red)
      false
    end
  end

  def ok(msg = nil)
    raise Ok.new(msg)
  end

  class Ok < StandardError
  end

end

class Hudson::FetchPlugin
  def initialize(progress, latest)
    @progress, @latest = progress, latest
  end

  def fetch(plugin)
    plugin = plugin.to_s
    metadata = OpenStruct.new(@latest['plugins'][plugin])
    @progress.means "upgrading #{plugin} plugin" do |step|
      system("cd lib/hudson/plugins && curl -L --silent #{metadata.url} > #{plugin}.hpi")
      step.ok(metadata.version)
    end
  end

end

namespace :hudson do
  
  desc "upgrade hudson server version, and bundled plugins to latest version"
  task :upgrade do
    progress = Hudson::Progress.new
    latest = progress.means "grabbing the latest metadata from hudson-ci.org" do |step|
      JSON.parse(HTTParty.get("http://hudson-ci.org/update-center.json").lines.to_a[1..-2].join("\n"))
    end
    progress.means "upgrading hudson server" do |step|
      latest_version = latest["core"]["version"]
      current_version = Hudson::HUDSON_VERSION
      if latest_version > current_version
        `cd lib/hudson && rm hudson.war && curl -L --silent #{latest["core"]["url"]} > hudson.war`
        File.open(File.expand_path(File.dirname(__FILE__) + '/../lib/hudson/hudson_version.rb'), "w") do |f|
          f.write <<-EOF
module Hudson
  HUDSON_VERSION = "#{latest["core"]["version"]}"
end

EOF
        end
        step.ok("#{current_version} -> #{latest_version}")
      else
        step.ok("Up-to-date at #{current_version}")
      end
    end

    plugins = Hudson::FetchPlugin.new(progress, latest)

    Dir['lib/hudson/plugins/*.hpi'].each do |plugin_file|
      plugins.fetch File.basename(plugin_file, ".hpi")
    end
  end
end