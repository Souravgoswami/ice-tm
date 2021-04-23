# frozen_string_literal: true
require_relative "lib/ice_tm/version"

Gem::Specification.new do |s|
	s.name = "ice_tm"
  s.version = IceTM::VERSION
	s.authors = ["Sourav Goswami"]
	s.email = ["souravgoswami@protonmail.com"]
	s.summary = "A controller for Arduino OLED System Monitor, ICE Task Manager"
	s.description = s.summary
	s.homepage = "https://github.com/souravgoswami/ice-tm"
	s.license = "MIT"
	s.required_ruby_version = Gem::Requirement.new(">= 2.6.0")
	s.files = Dir.glob(%w(exe/** ext/**/*.{c,h} lib/**/*.rb))
	s.executables = s.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
	s.require_paths = ["lib"]
  s.extensions = Dir.glob("ext/**/extconf.rb")
	s.bindir = "exe"
end
