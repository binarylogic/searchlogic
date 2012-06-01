# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "authlogic"
  s.version     = "2.5.8"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Ben Johnson"]
  s.email       = ["bjohnson@binarylogic.com"]
  s.homepage    = "http://github.com/binarylogic/searchlogic"
  s.summary     = %q{Searchlogic makes using ActiveRecord named scopes easier and less repetitive.}
  s.description = %q{Searchlogic makes using ActiveRecord named scopes easier and less repetitive.}

  s.add_dependency 'activerecord', '~> 2.3.12'
  s.add_dependency 'activesupport', '~> 2.3.12'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
