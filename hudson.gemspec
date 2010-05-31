# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{hudson}
  s.version = "0.2.5.pre"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.authors = ["Charles Lowell", "Nic Williams"]
  s.date = %q{2010-05-31}
  s.default_executable = %q{hudson}
  s.description = %q{A suite of utilities for bringing continous integration to your projects (not the other way around) with hudson CI}
  s.email = %q{cowboyd@thefrontside.net}
  s.executables = ["hudson"]
  s.files = ["bin", "bin/hudson", "features", "features/create_jobs.feature", "features/development.feature", "features/fixtures", "features/fixtures/projects", "features/fixtures/projects/ruby", "features/fixtures/projects/ruby/Rakefile", "features/step_definitions", "features/step_definitions/common_steps.rb", "features/step_definitions/fixture_project_steps.rb", "features/step_definitions/hudson_steps.rb", "features/step_definitions/scm_steps.rb", "features/support", "features/support/common.rb", "features/support/env.rb", "features/support/matchers.rb", "hudson.rb.gemspec", "lib", "lib/hudson", "lib/hudson/api.rb", "lib/hudson/hudson.war", "lib/hudson/job_config_builder.rb", "lib/hudson/plugins", "lib/hudson/plugins/git.hpi", "lib/hudson/plugins/github.hpi", "lib/hudson/plugins/greenballs.hpi", "lib/hudson/plugins/rake.hpi", "lib/hudson/plugins/ruby.hpi", "lib/hudson/project_scm.rb", "lib/hudson.rb", "Rakefile", "README.md", "spec", "spec/fixtures", "spec/fixtures/ec2_global.config.xml", "spec/fixtures/rails.multi.config.xml", "spec/fixtures/rails.single.config.xml", "spec/fixtures/rubygem.config.xml", "spec/fixtures/therubyracer.config.xml", "spec/job_config_builder_spec.rb", "spec/spec_helper.rb"]
  s.homepage = %q{http://github.com/cowboyd/hudson.rb}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{hudson}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Painless Continuous Integration with Hudson Server}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
