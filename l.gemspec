# encoding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'l/version'

Gem::Specification.new do |spec|
  spec.name          = "l"
  spec.version       = L::VERSION
  spec.authors       = ["Bartek Bulat", "Krzystof Kosman", "Ewelina Milaj", "Mateusz Luterek"]
  spec.email         = ["admin@1000i.pl"]
  spec.description   = %q{Gem for lazy programmers}
  spec.summary       = %q{Bunch of generators for lazy programmers}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/).delete_if do |file|
    file.match(/lib\/gem_tasks\/.*rake$/)
  end
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_runtime_dependency 'devise', '~> 2.0.0'
  spec.add_runtime_dependency 'paperclip'
  spec.add_runtime_dependency 'jquery-ui-rails'
  spec.add_runtime_dependency 'jquery-fileupload-rails'
  spec.add_runtime_dependency 'better_errors'
  spec.add_runtime_dependency 'binding_of_caller'
  spec.add_runtime_dependency 'quiet_assets'
  spec.add_runtime_dependency 'foundation-rails', '~> 5.2.0'
  spec.add_runtime_dependency 'font-awesome-rails', '~> 4.0.0'
  spec.add_runtime_dependency 'paranoia', '~> 1.0'
end
