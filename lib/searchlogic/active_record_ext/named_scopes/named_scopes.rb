module Searchlogic
  module ActiveRecordExt
    module NamedScopes
      module ClassMethods
        def scope(name, scope)
          named_scopes[name.to_sym] = {}
          named_scopes[name][:scope] = scope
          scope.arity == 0 ? named_scopes[name][:type] = :boolean : named_scopes[name][:type] = :unspecified
          super(name, scope)
        end


        def alias_scope(original_name, new_name, options ={:type => :unspecified})
          ##Searchlogic needs to be aware of defined scopes so it can allow you to assign it to a search object
          ##This is a security measure to prevent users from passing in destructive methods such as :destroy_all => true
          ## Searchlogic automatically registers the scope when defined with scope, :name, lambda However
          ## if you have a class level scope (e.g. def self.my_scope; <scope> end;) and want searchlogic to recognize it as safe you need to alias the scope
          ## so searchlogic can add it to a list of safe scopes.
          ## If you want searchlogic to typecast inputs values you must specify the type of input. 
          ## For scopes with an arity of 0, you should specify :boolean 

          singleton_class.instance_eval do 
            define_method(new_name) do |*args|
              send(original_name, *args)
            end
          end
          if named_scopes[original_name]
            named_scopes[new_name.to_sym] = named_scopes[original_name]
          else
            named_scopes[new_name.to_sym] = options
          end
        end
      end
    end
  end
end