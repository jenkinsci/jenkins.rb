require 'term/ansicolor'

module Hudson
  class CLI < Thor
    module Formatting
      module ClassMethods
        def task_help(shell, task_name)
          meth = normalize_task_name(task_name)
          task = all_tasks[meth]
          handle_no_task_error(meth) unless task

          shell.say "usage: #{banner(task)}"
          shell.say
          class_options_help(shell, nil => task.options.map { |_, o| o })
          # shell.say task.description
          # shell.say
        end


        def print_options(shell, options, grp = nil)
          return if options.empty?
          # shell.say "Options:"
          table = options.map do |option|
            prototype = if option.default
              " [#{option.default}]"
            elsif option.boolean
              ""
            elsif option.required?
              " #{option.banner}"
            else
              " [#{option.banner}]"
            end
            ["--#{option.name}#{prototype}", "\t",option.description]
          end
          shell.print_table(table, :ident => 2)
        end
      end

      module InstanceMethods
        def c
          Term::ANSIColor
        end
      end

      def self.included(receiver)
        receiver.extend         ClassMethods
        receiver.send :include, InstanceMethods
      end
    end
  end
end

