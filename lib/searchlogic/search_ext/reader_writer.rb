module Searchlogic
  module SearchExt
    module ReaderWriter
      private 
      def read_or_write_condition(scope_name, args)
        if authorized_scope?(scope_name) || column_name?(scope_name) || associated_column?(scope_name)
          args.empty? ? read_condition(scope_name) : write_condition(scope_name, args.first)
        else
          ::Kernel.send(:raise, UnknownConditionError, scope_name.to_s)
        end
      end
      
      def write_condition(key, value)
        overwrite_orderings(key)
        new_value = typecast(key, value)
        conditions[key] = new_value
        self
      end

      def read_condition(key)
        conditions.include?(key) ?  conditions[key] : conditions[key.to_s]
      end


      def overwrite_orderings(key)
        if ordering?(key)
          delete_condition(:ascend_by)
          delete_condition(:descend_by)
        end
      end

      def ordering?(key)
        key.to_s == "descend_by" || key.to_s == "ascend_by"
      end
    end
  end
end