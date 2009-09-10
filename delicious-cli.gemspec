# Generated by jeweler
# DO NOT EDIT THIS FILE
# Instead, edit Jeweler::Tasks in Rakefile, and run `rake gemspec`
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{delicious-cli}
  s.version = "0.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["epitron"]
  s.date = %q{2009-09-10}
  s.description = %q{A commandline tool which lets you download all your delicious.com links and search them (with pretty color-coded results).}
  s.email = %q{chris@ill-logic.com}
  s.executables = ["dels", "delicious"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    "lib/delicious-cli.rb",
     "lib/delicious-cli/api.rb",
     "lib/delicious-cli/db.rb",
     "lib/delicious-cli/display.rb",
     "lib/delicious-cli/log.rb",
     "lib/delicious-cli/settings.rb"
  ]
  s.homepage = %q{http://github.com/epitron/delicious-cli}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Delicious.com commandline interface}
  s.test_files = [
    "test/delicious-cli_test.rb",
     "test/test_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<httparty>, [">= 0"])
      s.add_runtime_dependency(%q<colorize>, [">= 0"])
    else
      s.add_dependency(%q<httparty>, [">= 0"])
      s.add_dependency(%q<colorize>, [">= 0"])
    end
  else
    s.add_dependency(%q<httparty>, [">= 0"])
    s.add_dependency(%q<colorize>, [">= 0"])
  end
end
