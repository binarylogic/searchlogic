module Searchlogic
  module ActiveRecordExt
    module ScopeProcedure
      module ClassMethods
        def scope_procedure(name, scope)
          singleton_class.instance_eval do
            define_method(name) do |*args|
              scope.call(*args)
            end
          end
          searchlogic_scopes.push(name)
        end
      end
    end
  end
end