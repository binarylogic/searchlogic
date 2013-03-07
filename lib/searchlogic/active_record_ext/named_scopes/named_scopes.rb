module Searchlogic
  module ActiveRecordExt
    module ScopeProcedure
      module ClassMethods
        def scope(name, scope)
          named_scopes[name.to_sym] = {}
          named_scopes[name][:scope] = scope
          scope.arity == 0 ? named_scopes[name][:type] = :boolean : named_scopes[name][:type] = :unspecified
          super(name, scope)
        end


        def alias_scope(original_name, new_name)
          singleton_class.instance_eval do 
            define_method(new_name) do |*args|
              send(original_name, *args)
            end
          end
          named_scopes[new_name.to_sym] = named_scopes[original_name]
        end
      end
    end
  end
end