module Searchlogic
  module ActiveRecordExt
    module ScopeProcedure
      module ClassMethods
        def scope(name, scope)
          named_scopes[name] = {:name => name}
          named_scopes[name][:scope] = scope
          scope.arity == 0 ? named_scopes[name][:type] = :boolean : named_scopes[name][:type] = :unspecified
          super(name, scope)
        end
      end
    end
  end
end