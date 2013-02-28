module Searchlogic
  module SearchExt
    module ReaderWriter
      private 
      def read_or_write_condition(scope_name, args)
        if authorized_scope?(scope_name) || column_name?(scope_name) || associated_column?(scope_name)
          args.empty? ? read_condition(scope_name) : write_condition(scope_name, args)
        else
          ::Kernel.send(:raise, UnknownConditionError, scope_name.to_s)
        end
      end
      
      def write_condition(key, value)
        new_value = reader_writer_sanitize(key, value)
        conditions[key.to_sym] = new_value
        conditions.delete(key.to_sym) if (new_value.kind_of?(String) || new_value.kind_of?(Array) ) && new_value.empty?
        self
      end

      def read_condition(key)
        conditions[key]
      end

      def reader_writer_sanitize(key, value)
        return value.flatten.first if value.flatten.first.nil?
        first_val = value.flatten
        one_value = first_val.first if first_val.kind_of?(Array) && first_val.size == 1
        new_value =  typecast(key, one_value || first_val)
        removed_empty = delete_empty_strings(new_value) if new_value.kind_of?(Array)
        removed_empty || new_value
      end
    end
  end
end