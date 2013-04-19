
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
            puts "  #{v.description}"
          end
        end

        desc "publisher", "publisher NAME", :desc => "single build step that run after the build is complete"
        def publisher(name)
          @name = name
          @step_class = "Publisher"
          template('templates/build_step.tt', "models/#{name.downcase}_publisher.rb")
        end

        desc "builder", "builder NAME", :desc => "single build step in the entire build process"
        def builder(name)
          @name = name
          @step_class = "Builder"
          template('templates/build_step.tt', "models/#{name.downcase}_builder.rb")
        end

        desc "wrapper", "wrapper NAME", :desc => "decorate a build with pre and post hooks"
        def wrapper(name)
          @name = name
          template('templates/build_wrapper.tt', "models/#{name.downcase}_wrapper.rb")
        end

        desc "node_property", "node_property NAME", :desc => "generate a node_property extension point"
        def node_property(name)
          @name = name
          template('templates/node_property.tt', "models/#{name.downcase}_property.rb")
        end

        desc "run_listener", "run_listener NAME", :desc => "receive notification of build events"
        def run_listener(name)
          @name = name
          template('templates/run_listener.tt', "models/#{name.downcase}_listener.rb")
        end

        desc "item_listener", "item_listener NAME", :desc => "receive notification of job change events"
        def item_listener(name)
          @name = name
          template('templates/item_listener.tt', "models/#{name.downcase}_listener.rb")
        end

        desc "computer_listener", "computer_listener NAME", :desc => "receive notification of computers events"
        def computer_listener(name)
          @name = name
          template('templates/computer_listener.tt', "models/#{name.downcase}_listener.rb")
        end
      end
    end
  end
end