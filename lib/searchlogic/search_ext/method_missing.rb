module Searchlogic
  module SearchExt
    module MethodMissing
      private
        def method_missing(method, *args, &block)
          scope_name = method.to_s.gsub(/=$/, '').to_sym
          if method.to_s == "delete"
            delete_condition(args)
          elsif valid_accessor?(scope_name,method)
            read_or_write_condition(scope_name, args)
          else
            ##Hack, fix
            begin
              delegate(method, args, &block)
            rescue
              klass.all.send(method, &block)  
            end
          end
        end

        def valid_accessor?(scope_name, method)
          authorized_scope?(scope_name) || column_name?(scope_name) || method.to_s.include?('=') || associated_column?(scope_name)
        end

    end
  end
end