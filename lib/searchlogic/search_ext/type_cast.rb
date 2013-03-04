module Searchlogic
  module SearchExt
    module TypeCast
      def typecast(method, *val)
        value = val.size == 1 ? val.first : val
        type = column_type(method, value)
        if value.kind_of?(Range)
          Range.new(typecast(method, value.first), typecast(method, value.last))
        elsif value.kind_of?(Array)
          value.collect{|v| typecast(method, v)}
        elsif
          column_for_type_cast = ::ActiveRecord::ConnectionAdapters::Column.new("", nil)
          column_for_type_cast.instance_variable_set(:@type, type)
          column_for_type_cast.type_cast(value)
        else klass.named_scopes.keys.include?(method)
          value          
        end
      end
      private 

        def column_type(method, value)
          if boolean_method?(method)
            :boolean
          elsif association_method = association_in_method(klass, method)
            column_type_in_association(association_method)
          else
            name = klass.column_names.sort_by(&:size).reverse.find{ |kcn| method.to_s.include?(kcn.to_s)}
            column = klass.columns.select{|kc| kc.name == name}.first
            column ? column.type : scope_type(method)
          end
        end

        def scope_type(method)
          if klass.named_scopes[method].arity == 0
            :boolean
          else
            :scope
          end
        end

        def association_in_method(current_klass, method)
          first_association = current_klass.reflect_on_all_associations.find{|a| /^#{a.name.to_s}/.match(method.to_s)}
          if first_association
            klassname = first_association.name.to_s
            new_method = /[#{klassname}|#{klassname.singularize}]_(.*)/.match(method)[1]
            [klassname, new_method]
          else
            nil
          end
        end

        def column_type_in_association(association_method)
          association, new_method = association_method
          new_klass = association.singularize.camelize.constantize
          #Since find returns the first  match, columns sorted by largest name so
          #more specicific names get matched first e.g. "username" matches itself before "user" incorrectly does
          columns = new_klass.columns.sort{|c1, c2| c2.name.size <=> c1.name.size } if new_klass.columns.kind_of?(Array) && new_klass.columns.size >1 
          column = columns.find{|kc| new_method.to_s.include?(kc.name.to_s)}
          ass_method = association_in_method(new_klass, new_method)
          column ? column.type : column_type_in_association(ass_method)
        end

        def boolean_method?(method)
          !!(["null", "nil", "blank", "present"].find{|m| method.to_s.include?(m)})
        end
    end
  end
end
