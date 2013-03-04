module Searchlogic
  module ActiveRecordExt
    module ScopeProcedure
      module ClassMethods
        def scope(name, scope)
          named_scopes[name] = scope
          ScopeReflection.defined_named_scopes.merge!(name =>[self, scope])
          super(name, scope)
        end
      end
    end
  end
end