module Searchlogic
  module ActiveRecordExt
    module ScopeProcedure
      module ClassMethods
        def scope(name, scope)
          named_scopes.push(name)
          super(name, scope)
        end
      end
    end
  end
end