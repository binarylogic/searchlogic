module Searchlogic
  module SearchExt
    module ReaderWriter
      private 
      def read_or_write_condition(scope_name, args)
        if authorized_scope?(scope_name) || associated_column?(scope_name)
          args.empty? ? read_condition(scope_name) : write_condition(scope_name, args)
        else
          ::Kernel.send(:raise, UnknownConditionError, scope_name.to_s)
        end
      end
      
      def write_condition(key, value)
        vals = value.flatten
        tap{  conditions[key.to_sym] = typecast(key, *vals) }
      end

      def read_condition(key)
        conditions[key]
      end
    end
  end
end