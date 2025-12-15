# -*- encoding: utf-8 -*-
# stub: hamli 0.5.1 ruby lib

Gem::Specification.new do |s|
  s.name = "hamli".freeze
  s.version = "0.5.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "changelog_uri" => "https://github.com/r7kamura/hamli/blob/main/CHANGELOG.md", "homepage_uri" => "https://github.com/r7kamura/hamli", "rubygems_mfa_required" => "true", "source_code_uri" => "https://github.com/r7kamura/hamli" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Ryo Nakamura".freeze]
  s.bindir = "exe".freeze
  s.date = "2022-06-28"
  s.email = ["r7kamura@gmail.com".freeze]
  s.homepage = "https://github.com/r7kamura/hamli".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.6.0".freeze)
  s.rubygems_version = "3.4.19".freeze
  s.summary = "Yet another implementation for Haml template language.".freeze

  s.installed_by_version = "3.4.19" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<temple>.freeze, [">= 0"])
end
