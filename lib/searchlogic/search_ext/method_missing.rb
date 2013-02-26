module Searchlogic
  module SearchExt
    module MethodMissing
      private
        def method_missing(method, *args, &block)
          scope_name = method.to_s.gsub(/=$/, '').to_sym
          if method.to_s == "delete"
            delete_condition(args)
          elsif authorized_scope?(scope_name) || column_name?(scope_name) || method.to_s.include?('=') || ordering?(scope_name) || associated_column?(scope_name)
            read_or_write_condition(scope_name, args)
          else
            delegate(method, args, &block)
          end
        end

        def ordering?(scope_name)
          scope_name.to_s == "ascend_by" || scope_name.to_s == "descend_by"
        end
    end
  end
end