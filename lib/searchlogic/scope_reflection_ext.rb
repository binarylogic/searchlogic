Dir[File.dirname(__FILE__) + '/scope_reflection_ext/*.rb'].each { |f| require(f) }
module Searchlogic
  module ScopeReflectionExt
    def self.included(klass)
      klass.class_eval do 
        include SearchlogicConditions
        extend ClassLevelMethods
        include NamedScopeMethods
        include InstanceMethods
        include ScopeLambda
        include Type
      end
    end
  end
end