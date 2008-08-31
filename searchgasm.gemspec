Gem::Specification.new do |s|
  s.name        = "searchgasm"
  s.version     = "0.9"
  s.summary     = "Orgasmic ActiveRecord searching"
  s.description = "Makes ActiveRecord searching easier, robust, and powerful. Automatic conditions, pagination support, object based searching, and more."
  s.email       = "bjohnson@binarylogic.com"
  s.homepage    = "http://github.com/binarylogic/searchgasm"
  s.author      = "Ben Johnson"
  s.files       = Dir["lib/*"]
  s.add_dependency("activerecord", "> 2.0.0")
end