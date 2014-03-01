# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{group_delegator}
  s.version = "0.1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Dave M"]
  s.date = %q{2011-03-17}
  s.description = %q{A wrapper that allows method calls to multiple objects with various concurrency models}
  s.email = %q{dmarti21@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    "Gemfile",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "examples/compare_to_map.rb",
    "examples/diff_w_map.rb",
    "examples/find_troublemakers.rb",
    "examples/remote_component_update_sim.rb",
    "examples/search_examples_with_benchmarks.rb",
    "group_delegator.gemspec",
    "lib/group_delegator.rb",
    "lib/group_delegator/group_delegator_instances.rb",
    "lib/group_delegator/group_delegator_klasses.rb",
    "lib/group_delegator/source_group.rb",
    "lib/group_delegator/source_helper.rb",
    "spec/group_delegator_instances_spec.rb",
    "spec/group_delegator_klasses_spec.rb",
    "spec/group_delegator_spec.rb",
    "spec/source_group_spec.rb",
    "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/forforf/group_delegator}
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Delegate to multiple objects concurrently}
  s.test_files = [
    "examples/compare_to_map.rb",
    "examples/diff_w_map.rb",
    "examples/find_troublemakers.rb",
    "examples/remote_component_update_sim.rb",
    "examples/search_examples_with_benchmarks.rb",
    "spec/group_delegator_instances_spec.rb",
    "spec/group_delegator_klasses_spec.rb",
    "spec/group_delegator_spec.rb",
    "spec/source_group_spec.rb",
    "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, ["~> 2.3.0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.5.2"])
      s.add_development_dependency(%q<rcov>, [">= 0"])
    else
      s.add_dependency(%q<rspec>, ["~> 2.3.0"])
      s.add_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.5.2"])
      s.add_dependency(%q<rcov>, [">= 0"])
    end
  else
    s.add_dependency(%q<rspec>, ["~> 2.3.0"])
    s.add_dependency(%q<bundler>, ["~> 1.0.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.5.2"])
    s.add_dependency(%q<rcov>, [">= 0"])
  end
end
