
module Jenkins
  class Plugin
    class CLI
      class Generate < Thor
        include Thor::Actions

        source_root File.dirname(__FILE__)

        argument :name

        desc "publisher", "publisher NAME", :desc => "generate a publish step definition"
        def publisher
          @step_class = "Publisher"
          template('templates/build_step.tt', "models/#{name.downcase}_publisher.rb")
        end

        desc "builder", "builder NAME", :desc => "generate a build step definition"
        def builder
          @step_class = "Builder"
          template('templates/build_step.tt', "models/#{name.downcase}_builder.rb")
        end

      end
    end
  end
end