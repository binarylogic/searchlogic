Dir[File.dirname(__FILE__) + '/scope_reflection_ext/*.rb'].each { |f| require(f) }
module Searchlogic
  module ScopeReflectionExt
    def self.included(klass)
      klass.class_eval do 
        extend Aliases
        extend ClassLevelMethods
        extend MatchAlias
        extend SearchlogicConditions
        include Type
      end
    end
  end
end