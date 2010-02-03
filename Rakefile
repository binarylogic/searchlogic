require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "searchlogic"
    gem.summary = "Searchlogic makes using ActiveRecord named scopes easier and less repetitive."
    gem.description = "Searchlogic makes using ActiveRecord named scopes easier and less repetitive."
    gem.email = "bjohnson@binarylogic.com"
    gem.homepage = "http://github.com/binarylogic/searchlogic"
    gem.authors = ["Ben Johnson of Binary Logic"]
    gem.rubyforge_project = "searchlogic"
    gem.add_dependency "activerecord", ">= 2.0.0"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => :spec
