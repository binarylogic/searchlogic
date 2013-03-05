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
          authorized_scope?(scope_name) || associated_column?(method)
        end

    end
  end
end