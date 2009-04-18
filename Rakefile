ENV['RDOCOPT'] = "-S -f html -T hanna"

require "rubygems"
require "hoe"
require File.dirname(__FILE__) << "/lib/searchlogic/version"

Hoe.new("Searchlogic", Searchlogic::Version::STRING) do |p|
  p.name = "searchlogic"
  p.author = "Ben Johnson of Binary Logic"
  p.email  = 'bjohnson@binarylogic.com'
  p.summary = "Object based ActiveRecord searching, ordering, pagination, and more!"
  p.description = "Object based ActiveRecord searching, ordering, pagination, and more!"
  p.url = "http://github.com/binarylogic/searchlogic"
  p.history_file = "CHANGELOG.rdoc"
  p.readme_file = "README.rdoc"
  p.extra_rdoc_files = ["CHANGELOG.rdoc", "README.rdoc"]
  p.remote_rdoc_dir = ''
  p.test_globs = ["test/*/test_*.rb", "test/*_test.rb", "test/*/*_test.rb"]
  p.extra_deps = %w(activesupport activerecord)
end