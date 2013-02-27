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
        new_value = typecast(key, value)
        conditions[key.to_sym] = new_value
        self
      end

      def read_condition(key)
        conditions.include?(key) ?  conditions[key] : conditions[key.to_s]
      end

    end
  end
end