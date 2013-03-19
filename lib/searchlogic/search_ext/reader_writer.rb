module Searchlogic
  module SearchExt
    module ReaderWriter
      private 
      def read_or_write_condition(scope_name, args)
        if authorized_scope?(scope_name) || associated_column?(scope_name)
          args.empty? ? read_condition(scope_name) : write_condition(scope_name, args)
        else
          ::Object.__send__(:raise, UnknownConditionError, scope_name.to_s)
        end
      end
      
      def write_condition(key, value)
        vals = value.flatten
        type = ScopeReflection.new(klass, key).type unless ordering?(key)
        casted_value = ordering?(key) ? value.first : TypeCaster.call(type, vals)
        conditions[key.to_sym] = casted_value
        self
      end

      def read_condition(key)
        conditions[key]
      end
    end
  end
end