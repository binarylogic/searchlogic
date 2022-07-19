# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require File.expand_path('../lib/searchlogic/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = "searchlogic"
  s.version     = Searchlogic::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Ben Johnson"]
  s.email       = ["bjohnson@binarylogic.com"]
  s.homepage    = "http://github.com/binarylogic/searchlogic"
  s.summary     = %q{Searchlogic makes using ActiveRecord named scopes easier and less repetitive.}
  s.description = %q{Searchlogic makes using ActiveRecord named scopes easier and less repetitive.}

  s.add_dependency 'rails', '~> 3.2.22.24' # Required for Rails LTS
  s.add_dependency 'activerecord'
  s.add_dependency 'activesupport'

  s.add_development_dependency 'rake', '< 11.0'
  s.add_development_dependency 'rspec', '~> 1.3.1'
  s.add_development_dependency 'timecop', '~> 0.5.9.1'
  s.add_development_dependency 'sqlite3', '~> 1.4.2'
  s.add_development_dependency 'appraisal', '0.4.1'
  s.add_development_dependency 'pry', '>= 0'


  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
