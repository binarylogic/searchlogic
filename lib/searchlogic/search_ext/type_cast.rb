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
          column_for_type_cast = ::ActiveRecord::ConnectionAdapters::Column.new("", nil)
          column_for_type_cast.instance_variable_set(:@type, type)
          column_for_type_cast.type_cast(value)
        end
      end
    end
  end
end
