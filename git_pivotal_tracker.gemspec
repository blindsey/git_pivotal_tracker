# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'git_pivotal_tracker/version'

Gem::Specification.new do |s|
  s.name        = "git_pivotal_tracker"
  s.version     = GitPivotalTracker::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Ben Lindsey"]
  s.email       = ["ben@cumulo.us"]
  s.homepage    = "https://github.com/blindsey/git_pivotal_tracker"
  s.summary     = "A git workflow integrated with Pivotal Tracker"
  s.description = "provides a set of git workflow tools to start and finish Pivotal Tracker stories in topic branches"

  s.required_rubygems_version = ">= 1.3.6"

  s.add_development_dependency "rspec"
  s.add_development_dependency "webmock"
  s.add_development_dependency "aruba"
  s.add_runtime_dependency "grit"
  s.add_runtime_dependency "pivotal-tracker"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']
end
