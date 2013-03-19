module Searchlogic
  module SearchExt
    module ReaderWriter
      private 
      def read_or_write_condition(scope_name, args)
        args.empty? ? read_condition(scope_name) : write_condition(scope_name, args)
      end
      
      def write_condition(key, value)
        vals = value.flatten
        type = ScopeReflection.new( key, klass).type unless ordering?(key)
        conditions[key.to_sym] = ordering?(key) ? value.first : TypeCaster.call(type, vals)
        self
      end

      def read_condition(key)
        conditions[key]
      end
    end
  end
end