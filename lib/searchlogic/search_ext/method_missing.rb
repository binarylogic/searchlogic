module Searchlogic
  module SearchExt
    module MethodMissing
      private
        def method_missing(method, *args, &block)
          scope_name = method.to_s.gsub(/=$/, '').to_sym
          
          if valid_accessor?(scope_name, method)
            read_or_write_condition(scope_name, args)
          else            
            delegate(method, args, &block)
          end
        end

        def valid_accessor?(scope_name, method)                    
          ScopeReflection.authorized?(scope_name) || associated_column?(method)
        end

        def ordering?(scope_name)
          scope_name.to_s == "order"
        end
    end
  end
end