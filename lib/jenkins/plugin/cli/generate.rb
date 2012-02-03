
module Jenkins
  class Plugin
    class CLI
      class Generate < Thor
        include Thor::Actions
        attr_reader :name
        default_task :help
        source_root File.dirname(__FILE__)

        def self.help(shell, task)
          shell.say "Usage: jpi generate GENERATOR"
          shell.say "Available Generators:"
          tasks.each do |k, v|
            next if k.to_s == 'help'
            puts "  #{k}"
          end
        end

        desc "publisher", "publisher NAME", :desc => "generate a publish step definition"
        def publisher(name)
          @name = name
          @step_class = "Publisher"
          template('templates/build_step.tt', "models/#{name.downcase}_publisher.rb")
        end

        desc "builder", "builder NAME", :desc => "generate a build step definition"
        def builder(name)
          @name = name
          @step_class = "Builder"
          template('templates/build_step.tt', "models/#{name.downcase}_builder.rb")
        end

        desc "wrapper", "wrapper NAME", :desc => "generate a build wrapper"
        def wrapper(name)
          @name = name
          template('templates/build_wrapper.tt', "models/#{name.downcase}_wrapper.rb")
        end

        desc "node_property", "node_property NAME", :desc => "generate a node_property extension point"
        def node_property(name)
          @name = name
          template('templates/node_property.tt', "models/#{name.downcase}_property.rb")
        end

        desc "run_listener", "run_listener NAME", :desc => "create a new run listener"
        def run_listener(name)
          @name = name
          template('templates/run_listener.tt', "models/#{name.downcase}_listener.rb")
        end
      end
    end
  end
end