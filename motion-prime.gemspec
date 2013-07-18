# -*- encoding: utf-8 -*-
require File.expand_path('../motion-prime/version', __FILE__)

Gem::Specification.new do |spec|
  spec.name          = "motion-prime"
  spec.version       = MotionPrime::VERSION
  spec.authors       = ["Iskander Haziev"]
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
  spec.add_dependency "cocoapods"
  spec.add_dependency "motion-cocoapods"
  spec.add_dependency "motion-require"
  spec.add_dependency "motion-support"
  spec.add_dependency 'bubble-wrap'
  spec.add_dependency 'sugarcube'
  spec.add_dependency 'nano-store'
end
