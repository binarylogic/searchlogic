Dir[File.dirname(__FILE__) + '/scope_reflection_ext/*.rb'].each { |f| require(f) }
module Searchlogic
  module ScopeReflectionExt
    def self.included(klass)
      klass.class_eval do 
        extend Aliases
        include Scopes
        include Column
        extend ClassLevelVariables
        extend MatchAlias
        extend SearchlogicConditions
      end
    end
  end
end