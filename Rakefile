require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "searchlogic"
    gem.summary = "Searchlogic provides common named scopes and object based searching for ActiveRecord."
    gem.description = "Searchlogic provides common named scopes and object based searching for ActiveRecord."
    gem.email = "bjohnson@binarylogic.com"
    gem.homepage = "http://github.com/binarylogic/searchlogic"
    gem.authors = ["Ben Johnson of Binary Logic"]
    gem.rubyforge_project = "searchlogic"
    gem.add_dependency "activerecord", ">= 2.0.0"
  end
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


task :default => :spec

begin
  require 'rake/contrib/sshpublisher'
  namespace :rubyforge do
    desc "Release gem to RubyForge"
    task :release => ["rubyforge:release:gem"]
  end
rescue LoadError
  puts "Rake SshDirPublisher is unavailable or your rubyforge environment is not configured."
end
