module Searchlogic
  module ActiveRecordExt
    module ScopeProcedure
      module ClassMethods
        def scope(name, scope)
          named_scopes[name] = scope
          super(name, scope)
        end
      end
    end
  end
end