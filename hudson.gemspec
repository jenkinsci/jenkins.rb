# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{hudson}
  s.version = "0.3.0.beta.16"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.authors = ["Charles Lowell", "Dr Nic Williams"]
  s.date = %q{2010-11-02}
  s.default_executable = %q{hudson}
  s.description = %q{A suite of utilities for bringing continous integration to your projects (not the other way around) with hudson CI}
  s.email = ["cowboyd@thefrontside.net", "drnicwilliams@gmail.com"]
  s.executables = ["hudson"]
  s.files = ["bin", "bin/hudson", "features", "features/development.feature", "features/launch_server.feature", "features/listing_jobs.feature", "features/manage_jobs.feature", "features/manage_slave_nodes.feature", "features/step_definitions", "features/step_definitions/common_steps.rb", "features/step_definitions/fixture_project_steps.rb", "features/step_definitions/hudson_steps.rb", "features/step_definitions/scm_steps.rb", "features/support", "features/support/common.rb", "features/support/env.rb", "features/support/hooks.rb", "features/support/matchers.rb", "fixtures", "fixtures/projects", "fixtures/projects/non-bundler", "fixtures/projects/non-bundler/Rakefile", "fixtures/projects/rails-3", "fixtures/projects/rails-3/app", "fixtures/projects/rails-3/app/controllers", "fixtures/projects/rails-3/app/controllers/application_controller.rb", "fixtures/projects/rails-3/app/helpers", "fixtures/projects/rails-3/app/helpers/application_helper.rb", "fixtures/projects/rails-3/app/mailers", "fixtures/projects/rails-3/app/models", "fixtures/projects/rails-3/app/views", "fixtures/projects/rails-3/app/views/layouts", "fixtures/projects/rails-3/app/views/layouts/application.html.erb", "fixtures/projects/rails-3/config", "fixtures/projects/rails-3/config/application.rb", "fixtures/projects/rails-3/config/boot.rb", "fixtures/projects/rails-3/config/database.yml", "fixtures/projects/rails-3/config/environment.rb", "fixtures/projects/rails-3/config/environments", "fixtures/projects/rails-3/config/environments/development.rb", "fixtures/projects/rails-3/config/environments/production.rb", "fixtures/projects/rails-3/config/environments/test.rb", "fixtures/projects/rails-3/config/initializers", "fixtures/projects/rails-3/config/initializers/backtrace_silencers.rb", "fixtures/projects/rails-3/config/initializers/inflections.rb", "fixtures/projects/rails-3/config/initializers/mime_types.rb", "fixtures/projects/rails-3/config/initializers/secret_token.rb", "fixtures/projects/rails-3/config/initializers/session_store.rb", "fixtures/projects/rails-3/config/locales", "fixtures/projects/rails-3/config/locales/en.yml", "fixtures/projects/rails-3/config/routes.rb", "fixtures/projects/rails-3/config.ru", "fixtures/projects/rails-3/db", "fixtures/projects/rails-3/db/seeds.rb", "fixtures/projects/rails-3/doc", "fixtures/projects/rails-3/doc/README_FOR_APP", "fixtures/projects/rails-3/Gemfile", "fixtures/projects/rails-3/Gemfile.lock", "fixtures/projects/rails-3/lib", "fixtures/projects/rails-3/lib/tasks", "fixtures/projects/rails-3/log", "fixtures/projects/rails-3/log/development.log", "fixtures/projects/rails-3/log/production.log", "fixtures/projects/rails-3/log/server.log", "fixtures/projects/rails-3/log/test.log", "fixtures/projects/rails-3/public", "fixtures/projects/rails-3/public/404.html", "fixtures/projects/rails-3/public/422.html", "fixtures/projects/rails-3/public/500.html", "fixtures/projects/rails-3/public/favicon.ico", "fixtures/projects/rails-3/public/images", "fixtures/projects/rails-3/public/images/rails.png", "fixtures/projects/rails-3/public/index.html", "fixtures/projects/rails-3/public/javascripts", "fixtures/projects/rails-3/public/javascripts/application.js", "fixtures/projects/rails-3/public/javascripts/controls.js", "fixtures/projects/rails-3/public/javascripts/dragdrop.js", "fixtures/projects/rails-3/public/javascripts/effects.js", "fixtures/projects/rails-3/public/javascripts/prototype.js", "fixtures/projects/rails-3/public/javascripts/rails.js", "fixtures/projects/rails-3/public/robots.txt", "fixtures/projects/rails-3/public/stylesheets", "fixtures/projects/rails-3/Rakefile", "fixtures/projects/rails-3/README", "fixtures/projects/rails-3/script", "fixtures/projects/rails-3/script/rails", "fixtures/projects/rails-3/test", "fixtures/projects/rails-3/test/fixtures", "fixtures/projects/rails-3/test/functional", "fixtures/projects/rails-3/test/integration", "fixtures/projects/rails-3/test/performance", "fixtures/projects/rails-3/test/performance/browsing_test.rb", "fixtures/projects/rails-3/test/test_helper.rb", "fixtures/projects/rails-3/test/unit", "fixtures/projects/rails-3/vendor", "fixtures/projects/rails-3/vendor/plugins", "fixtures/projects/ruby", "fixtures/projects/ruby/Gemfile", "fixtures/projects/ruby/Gemfile.lock", "fixtures/projects/ruby/Rakefile", "Gemfile", "Gemfile.lock", "hudson.gemspec", "lib", "lib/hudson", "lib/hudson/api.rb", "lib/hudson/cli", "lib/hudson/cli/formatting.rb", "lib/hudson/cli.rb", "lib/hudson/config.rb", "lib/hudson/core_ext", "lib/hudson/core_ext/object", "lib/hudson/core_ext/object/blank.rb", "lib/hudson/hudson-cli.jar", "lib/hudson/hudson.war", "lib/hudson/hudson_version.rb", "lib/hudson/job_config_builder.rb", "lib/hudson/plugins", "lib/hudson/plugins/envfile.hpi", "lib/hudson/plugins/git.hpi", "lib/hudson/plugins/github.hpi", "lib/hudson/plugins/greenballs.hpi", "lib/hudson/plugins/rake.hpi", "lib/hudson/plugins/ruby.hpi", "lib/hudson/project_scm.rb", "lib/hudson/remote.rb", "lib/hudson/version.rb", "lib/hudson.rb", "Rakefile", "README.md", "spec", "spec/fixtures", "spec/fixtures/ec2_global.config.xml", "spec/fixtures/rails.multi.config.xml", "spec/fixtures/rails.single.config.triggers.xml", "spec/fixtures/rails.single.config.xml", "spec/fixtures/ruby.single.config.xml", "spec/fixtures/rubygem.config.xml", "spec/fixtures/therubyracer.config.xml", "spec/job_config_builder_spec.rb", "spec/spec_helper.rb", "tasks", "tasks/upgrade.rake"]
  s.homepage = %q{http://github.com/cowboyd/hudson.rb}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{hudson}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Painless Continuous Integration with Hudson Server}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<term-ansicolor>, [">= 1.0.4"])
      s.add_runtime_dependency(%q<yajl-ruby>, [">= 0.7.6"])
      s.add_runtime_dependency(%q<httparty>, ["~> 0.6.1"])
      s.add_runtime_dependency(%q<builder>, ["~> 2.1.2"])
      s.add_runtime_dependency(%q<thor>, ["= 0.14.2"])
      s.add_runtime_dependency(%q<hpricot>, [">= 0"])
      s.add_development_dependency(%q<rake>, ["~> 0.8.7"])
      s.add_development_dependency(%q<cucumber>, ["~> 0.9.0"])
      s.add_development_dependency(%q<rspec>, ["~> 2.0.0"])
      s.add_development_dependency(%q<json>, ["~> 1.4.0"])
      s.add_development_dependency(%q<awesome_print>, [">= 0"])
    else
      s.add_dependency(%q<term-ansicolor>, [">= 1.0.4"])
      s.add_dependency(%q<yajl-ruby>, [">= 0.7.6"])
      s.add_dependency(%q<httparty>, ["~> 0.6.1"])
      s.add_dependency(%q<builder>, ["~> 2.1.2"])
      s.add_dependency(%q<thor>, ["= 0.14.2"])
      s.add_dependency(%q<hpricot>, [">= 0"])
      s.add_dependency(%q<rake>, ["~> 0.8.7"])
      s.add_dependency(%q<cucumber>, ["~> 0.9.0"])
      s.add_dependency(%q<rspec>, ["~> 2.0.0"])
      s.add_dependency(%q<json>, ["~> 1.4.0"])
      s.add_dependency(%q<awesome_print>, [">= 0"])
    end
  else
    s.add_dependency(%q<term-ansicolor>, [">= 1.0.4"])
    s.add_dependency(%q<yajl-ruby>, [">= 0.7.6"])
    s.add_dependency(%q<httparty>, ["~> 0.6.1"])
    s.add_dependency(%q<builder>, ["~> 2.1.2"])
    s.add_dependency(%q<thor>, ["= 0.14.2"])
    s.add_dependency(%q<hpricot>, [">= 0"])
    s.add_dependency(%q<rake>, ["~> 0.8.7"])
    s.add_dependency(%q<cucumber>, ["~> 0.9.0"])
    s.add_dependency(%q<rspec>, ["~> 2.0.0"])
    s.add_dependency(%q<json>, ["~> 1.4.0"])
    s.add_dependency(%q<awesome_print>, [">= 0"])
  end
end
