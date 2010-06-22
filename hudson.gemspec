# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{hudson}
  s.version = "0.2.5.pre2"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.authors = ["Charles Lowell", "Dr Nic Williams"]
  s.date = %q{2010-06-22}
  s.default_executable = %q{hudson}
  s.description = %q{A suite of utilities for bringing continous integration to your projects (not the other way around) with hudson CI}
  s.email = ["cowboyd@thefrontside.net", "drnicwilliams@gmail.com"]
  s.executables = ["hudson"]
  s.files = ["bin", "bin/hudson", "features", "features/create_jobs.feature", "features/development.feature", "features/fixtures", "features/fixtures/projects", "features/fixtures/projects/ruby", "features/fixtures/projects/ruby/Rakefile", "features/managing_remote_servers.feature", "features/server.feature", "features/step_definitions", "features/step_definitions/common_steps.rb", "features/step_definitions/fixture_project_steps.rb", "features/step_definitions/hudson_steps.rb", "features/step_definitions/scm_steps.rb", "features/support", "features/support/common.rb", "features/support/env.rb", "features/support/hooks.rb", "features/support/matchers.rb", "hudson.gemspec", "lib", "lib/hudson", "lib/hudson/api.rb", "lib/hudson/cli", "lib/hudson/cli/formatting.rb", "lib/hudson/cli.rb", "lib/hudson/hudson.war", "lib/hudson/job_config_builder.rb", "lib/hudson/plugins", "lib/hudson/plugins/git.hpi", "lib/hudson/plugins/github.hpi", "lib/hudson/plugins/greenballs.hpi", "lib/hudson/plugins/rake.hpi", "lib/hudson/plugins/ruby.hpi", "lib/hudson/project_scm.rb", "lib/hudson.rb", "Rakefile", "README.md", "spec", "spec/fixtures", "spec/fixtures/ec2_global.config.xml", "spec/fixtures/rails.multi.config.xml", "spec/fixtures/rails.single.config.xml", "spec/fixtures/rubygem.config.xml", "spec/fixtures/therubyracer.config.xml", "spec/job_config_builder_spec.rb", "spec/spec_helper.rb"]
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
      s.add_runtime_dependency(%q<httparty>, ["~> 0.5.2"])
      s.add_runtime_dependency(%q<builder>, ["~> 2.1.2"])
      s.add_runtime_dependency(%q<thor>, ["~> 0.13.6"])
      s.add_runtime_dependency(%q<hpricot>, [">= 0"])
      s.add_development_dependency(%q<cucumber>, ["~> 0.7.3"])
      s.add_development_dependency(%q<rspec>, ["~> 1.3.0"])
      s.add_development_dependency(%q<json>, ["~> 1.4.0"])
    else
      s.add_dependency(%q<term-ansicolor>, [">= 1.0.4"])
      s.add_dependency(%q<yajl-ruby>, [">= 0.7.6"])
      s.add_dependency(%q<httparty>, ["~> 0.5.2"])
      s.add_dependency(%q<builder>, ["~> 2.1.2"])
      s.add_dependency(%q<thor>, ["~> 0.13.6"])
      s.add_dependency(%q<hpricot>, [">= 0"])
      s.add_dependency(%q<cucumber>, ["~> 0.7.3"])
      s.add_dependency(%q<rspec>, ["~> 1.3.0"])
      s.add_dependency(%q<json>, ["~> 1.4.0"])
    end
  else
    s.add_dependency(%q<term-ansicolor>, [">= 1.0.4"])
    s.add_dependency(%q<yajl-ruby>, [">= 0.7.6"])
    s.add_dependency(%q<httparty>, ["~> 0.5.2"])
    s.add_dependency(%q<builder>, ["~> 2.1.2"])
    s.add_dependency(%q<thor>, ["~> 0.13.6"])
    s.add_dependency(%q<hpricot>, [">= 0"])
    s.add_dependency(%q<cucumber>, ["~> 0.7.3"])
    s.add_dependency(%q<rspec>, ["~> 1.3.0"])
    s.add_dependency(%q<json>, ["~> 1.4.0"])
  end
end
