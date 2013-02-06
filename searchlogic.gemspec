# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
Gem::Specification.new do |s|
  s.name        = "searchlogic"
  s.version   = "3.0.0"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Ben Johnson"]
  s.email       = ["bjohnson@binarylogic.com"]
  s.homepage    = "http://github.com/binarylogic/searchlogic"
  s.summary     = %q{Searchlogic makes using ActiveRecord named scopes easier and less repetitive.}
  s.description = %q{Searchlogic makes using ActiveRecord named scopes easier and less repetitive.}

  s.add_dependency 'activerecord', '3.2.11'
  s.add_dependency 'activesupport', '3.2.11'
  s.add_development_dependency 'debugger'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rspec', '2.12.0'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'appraisal', '0.5.1'
  s.add_development_dependency  "database_cleaner", "0.9.1"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end