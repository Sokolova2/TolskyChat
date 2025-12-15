# -*- encoding: utf-8 -*-
# stub: rubocop-haml 0.3.1 ruby lib

Gem::Specification.new do |s|
  s.name = "rubocop-haml".freeze
  s.version = "0.3.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "changelog_uri" => "https://github.com/r7kamura/rubocop-haml/releases", "default_lint_roller_plugin" => "RuboCop::Haml::Plugin", "homepage_uri" => "https://github.com/r7kamura/rubocop-haml", "source_code_uri" => "https://github.com/r7kamura/rubocop-haml" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Ryo Nakamura".freeze]
  s.bindir = "exe".freeze
  s.date = "2025-04-10"
  s.email = ["r7kamura@gmail.com".freeze]
  s.homepage = "https://github.com/r7kamura/rubocop-haml".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.7.0".freeze)
  s.rubygems_version = "3.4.19".freeze
  s.summary = "RuboCop plugin for Haml template.".freeze

  s.installed_by_version = "3.4.19" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<hamli>.freeze, ["~> 0.5"])
  s.add_runtime_dependency(%q<lint_roller>.freeze, [">= 1.1"])
  s.add_runtime_dependency(%q<rubocop>.freeze, [">= 1.72.1"])
end
