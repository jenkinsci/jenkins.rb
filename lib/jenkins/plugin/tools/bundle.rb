
module Jenkins
  class Plugin
    module Tools
      class Bundle

        def initialize(target)
          @target = target
        end

        def install
          require 'java'
          require 'bundler'
          puts "bundling..."

          # We set these in ENV instead of passing the --without and --path
          # options because the CLI options are remembered in .bundle/config and
          # will interfere with regular usage of bundle exec / install.
          Bundler.with_clean_env {
            ENV['BUNDLE_APP_CONFIG'] = "#{@target}/vendor/bundle"
            ENV['BUNDLE_WITHOUT'] =  "development"
            ENV['BUNDLE_PATH'] = "#{@target}/vendor/gems"
            ENV.delete 'RUBYOPT'
            system('bundle --standalone')
          }
        end
      end
    end
  end
end
