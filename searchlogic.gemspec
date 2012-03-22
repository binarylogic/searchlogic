# -*- encoding: utf-8 -*-
require File.expand_path('../lib/searchlogic/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Ben Johnson of Binary Logic"]
  gem.email         = ["bjohnson@binarylogic.com"]
  gem.description   = "Searchlogic makes using ActiveRecord named scopes easier and less repetitive."
  gem.summary       = gem.description
  gem.homepage      = "http://github.com/binarylogic/searchlogic"

  gem.files         = `git ls-files`.split($\)
  # gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "searchlogic"
  gem.require_paths = ["lib"]
  gem.version       = Searchlogic::VERSION
  
  gem.extra_rdoc_files = [
    "LICENSE",
    "README.rdoc"
  ]
  # gem.date = %q{2011-08-15}
  
  
  gem.add_runtime_dependency 'activerecord', '~> 2.3.12'
  gem.add_development_dependency 'jeweler'
  # gem.add_development_dependency 'ruby-debug19'
  gem.add_development_dependency 'rspec', '~> 1.3.1'
  gem.add_development_dependency 'sqlite3'
end

