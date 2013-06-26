# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'carrierwave/elasticsearch/version'

Gem::Specification.new do |s|
  s.name          = "carrierwave-elasticsearch"
  s.version       = CarrierWave::Elasticsearch::VERSION
  s.platform      = Gem::Platform::RUBY
  s.authors       = ["Spencer Markowski"]
  s.email         = ["spencer@theablefew.com"]
  s.homepage      = "https://github.com/esmarkowski/carrierwave-riak"
  s.summary       = %q{Elasticsearch Storage support for CarrierWave}
  s.description   = %q{Elasticsearch Storage support for CarrierWave}
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "carrierwave"
  s.add_dependency "rubberband", "~> 0.9"
  s.add_dependency "thrift", "~> 0.9"

  s.add_development_dependency "rails", "~> 3.0"
  s.add_development_dependency "rspec", "~> 2.13"
end
