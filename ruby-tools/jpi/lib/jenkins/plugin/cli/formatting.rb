
module Jenkins
  class Plugin
    class CLI < Thor
      module Formatting
        def task_help(shell, task_name)
          meth = normalize_task_name(task_name)
          task = all_tasks[meth]
          handle_no_task_error(meth) unless task

          shell.say "usage: #{banner(task)}"
          shell.say
          class_options_help(shell, nil => task.options.map { |_, o| o })
        end


        def print_options(shell, options, grp = nil)
          return if options.empty?
          table = options.map do |option|
            prototype = if option.default
              " [#{option.default}]"
            elsif option.type == :boolean
              ""
            elsif option.required?
              " #{option.banner}"
            else
              " [#{option.banner}]"
            end
            aliases = option.aliases.empty? ? "" : option.aliases.join(" ") + ","
            [aliases, "--#{option.name}#{prototype}", "\t",option.description]
          end
          shell.print_table(table, :indent => 2)
          shell.say
        end

        def help(shell, task)
          list = printable_tasks
          print shell.set_color("jpi", :black, true)
          shell.say <<-USAGE
 - tools to create, build, develop and release Jenkins plugins

Usage: jpi command [arguments] [options]

USAGE

          shell.say "Commands:"
          shell.print_table(list, :indent => 2, :truncate => true)
          shell.say
          class_options_help(shell)
        end
      end
    end
  end
end