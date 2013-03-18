module Searchlogic
  module SearchExt
    module TypeCast
      def typecast(method, *val)
        value = val.size == 1 ? val.first : val
        return value if ordering?(method)
        type = ScopeReflection.new(klass, method).type
        if value.kind_of?(Range)
          Range.new(typecast(method, value.first), typecast(method, value.last))
        elsif value.kind_of?(Array)
          value.collect{|v| typecast(method, v)}
        else
          typecaster = TypeCaster.new(value, type)
          typecaster.column_type 
        end
      end

      def ordering?(scope_name)
        scope_name.to_s == "order"
      end
      
    end
  end
end
