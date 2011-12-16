# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "delicious-cli"
  s.version = "0.5.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["epitron"]
  s.date = "2011-12-14"
  s.description = "A commandline tool which lets you download all your delicious.com links and search them (with pretty color-coded results)."
  s.email = "chris@ill-logic.com"
  s.executables = ["delicious", "dels"]
  s.extra_rdoc_files = [
    "LICENSE",
    "README.rdoc"
  ]
  s.files = [
    "lib/delicious-cli.rb",
    "lib/delicious-cli/api.rb",
    "lib/delicious-cli/blank.rb",
    "lib/delicious-cli/colored.rb",
    "lib/delicious-cli/db.rb",
    "lib/delicious-cli/display.rb",
    "lib/delicious-cli/log.rb",
    "lib/delicious-cli/settings.rb"
  ]
  s.homepage = "http://github.com/epitron/delicious-cli"
  s.post_install_message = "\n========================================================================\nDelicious-CLI installed!\n------------------------------------------------------------------------\n\nTo configure your Delicious.com account, type:\n\n  $ dels\n  \nTo search, type:\n\n  $ dels <search term(s)>\n\nTo pull new links from your delicious account, type:\n\n  $ dels -s\n  \nTo add dels -s to your crontab, type:\n\n  $ crontab -e\n  \nThat's all, folks!\n  \n========================================================================\n"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.10"
  s.summary = "Delicious.com commandline interface"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<httparty>, [">= 0"])
    else
      s.add_dependency(%q<httparty>, [">= 0"])
    end
  else
    s.add_dependency(%q<httparty>, [">= 0"])
  end
end

