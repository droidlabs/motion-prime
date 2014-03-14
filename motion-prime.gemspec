# -*- encoding: utf-8 -*-
require File.expand_path('../motion-prime/version', __FILE__)

Gem::Specification.new do |spec|
  spec.name          = "motion-prime"
  spec.version       = MotionPrime::VERSION
  spec.authors       = ["Iskander Haziev", "Pavel Feklistov"]
  spec.email         = ["gvalmon@gmail.com"]
  spec.description   = %q{RubyMotion apps development framework}
  spec.summary       = %q{RubyMotion apps development framework}
  spec.homepage      = ""
  spec.license       = ""

  spec.files         = `git ls-files`.split($\)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake"
  spec.add_development_dependency("motion-stump")
  spec.add_development_dependency("motion-redgreen")

  spec.add_dependency "cocoapods"
  spec.add_dependency "motion-cocoapods"
  spec.add_dependency "motion-require"
  spec.add_dependency "motion-support", '~> 0.2.6'
  spec.add_dependency 'bubble-wrap', '~> 1.5.0'
  spec.add_dependency 'sugarcube', '~> 1.5.2'
  spec.add_dependency 'afmotion', '~> 2.0.0'
  spec.add_dependency "methadone"
  spec.add_dependency "rm-digest" 
  spec.add_dependency "thor" 
  spec.add_dependency "activesupport" 
end
