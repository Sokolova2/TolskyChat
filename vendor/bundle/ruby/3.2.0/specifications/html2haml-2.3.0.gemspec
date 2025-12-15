# -*- encoding: utf-8 -*-
# stub: html2haml 2.3.0 ruby lib

Gem::Specification.new do |s|
  s.name = "html2haml".freeze
  s.version = "2.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Akira Matsuda".freeze, "Stefan Natchev".freeze]
  s.date = "2022-10-06"
  s.description = "Converts HTML into Haml".freeze
  s.email = ["ronnie@dio.jp".freeze, "stefan.natchev@gmail.com".freeze]
  s.executables = ["html2haml".freeze]
  s.files = ["bin/html2haml".freeze]
  s.homepage = "http://haml.info".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.2".freeze)
  s.rubygems_version = "3.4.19".freeze
  s.summary = "Converts HTML into Haml".freeze

  s.installed_by_version = "3.4.19" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<nokogiri>.freeze, [">= 1.6.0"])
  s.add_runtime_dependency(%q<erubis>.freeze, ["~> 2.7.0"])
  s.add_runtime_dependency(%q<ruby_parser>.freeze, ["~> 3.5"])
  s.add_runtime_dependency(%q<haml>.freeze, [">= 4.0"])
  s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.7.1"])
  s.add_development_dependency(%q<minitest>.freeze, [">= 4.4.0"])
  s.add_development_dependency(%q<rake>.freeze, [">= 0"])
end
