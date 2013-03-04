module Searchlogic
  module SearchExt
    module TypeCast
      def typecast(method, *val)
        value = val.size == 1 ? val.first : val
        type = ScopeReflection.new(klass, method).column_type        
        type = column_type(method, value)
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
      private 

        def column_type(method, value)
          binding.pry
          if boolean_method?(method)
            :boolean
          elsif 
            column_type_in_association(association_method)
          else
            name = klass.column_names.sort_by(&:size).reverse.find{ |kcn| method.to_s.include?(kcn.to_s)}
            column = klass.columns.select{|kc| kc.name == name}.first
            column ? column.type : scope_type(method)
          end
        end

        def scope_type(method)
          if klass.named_scopes[method] && klass.named_scopes[method].arity == 0
            :boolean
          else
            :scope
          end
        end

        def boolean_method?(method)
          !!(["null", "nil", "blank", "present"].find{|m| method.to_s.include?(m)})
        end
    end
  end
end
