# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'logginator/version'

Gem::Specification.new do |spec|
  spec.name          = "logginator"
  spec.version       = Logginator::VERSION
  spec.authors       = ["Dan Shultz"]
  spec.email         = ["das0118@gmail.com"]
  spec.summary       = %q{Command line tool to parse logs and roll counts}
  spec.homepage      = "https://github.com/danshultz/logginator"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "mixlib-cli", "~>1.4.0"

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "mocha"
end
