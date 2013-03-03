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
        elsif klass.named_scopes.include?(method)
          value
        else
          column_for_type_cast = ::ActiveRecord::ConnectionAdapters::Column.new("", nil)
          column_for_type_cast.instance_variable_set(:@type, type)
          column_for_type_cast.type_cast(value)
        end
      end
      private 

        def column_type(method, value)
          ##Custom scopes
          if boolean_method?(method)
            :boolean
          elsif association_method = association_in_method(klass, method)
            column_type_in_association(association_method)
          else
            name = klass.column_names.sort_by(&:size).reverse.find{ |kcn| method.to_s.include?(kcn.to_s)}
            column = klass.columns.select{|kc| kc.name == name}.first
            column ? column.type : :scope
          end
        end

        def association_in_method(current_klass, method)
          association_candidates = current_klass.reflect_on_all_associations.select{|a| method.to_s.include?(a.name.to_s)}
          if !association_candidates.empty?
            first_association = /^#{association_candidates.map(&:name).join("|")}/.match(method.to_s)[0]
            klassname = first_association
            new_method = /[#{klassname}|#{klassname.singularize}]_(.*)/.match(method)[1]
            [klassname, new_method]
          else
            nil
          end
        end

        def column_type_in_association(association_method)
          association, new_method = association_method
          new_klass = association.singularize.camelize.constantize
          column = new_klass.columns.find{|kc| new_method.to_s.include?(kc.name.to_s)}
          column = column.sort_by{|c1, c2| c.name.size <=> c.name.size } if column.kind_of?(Array) 
          ass_method = association_in_method(new_klass, new_method)
          column ? column.type : column_type_in_association(ass_method)
        end

        def boolean_method?(method)
          !!(["null", "nil", "blank", "present"].find{|m| method.to_s.include?(m)})
        end
    end
  end
end
