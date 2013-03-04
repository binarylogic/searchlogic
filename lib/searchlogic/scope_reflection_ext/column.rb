module Searchlogic
  module ScopeReflectionExt
    module Column

      def column_name
        column_names = klass.column_names.sort_by(&:size).reverse
        column_names.find{|cn| method.to_s.include?(cn.to_s)}
      end

      def column_type
        @column_type || klass.columns.find{ |kc| kc.name == column_name}.type
      end

      def column_type=(type)
        @column_type = type
      end
      
    end
  end
end