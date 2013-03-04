module Searchlogic
  module ScopeReflectionExt
    module Column

      def column_name
        column_names = klass.column_names.sort_by(&:size).reverse
        column_names.find{|cn| method.to_s.include?(cn.to_s)}
      end

      def column_type
        @column_type || calculated_column_type

      end


      def column_type=(type)
        @column_type = type
      end
      private 

      def calculated_column_type
        if association_method = association_in_method(klass, method)
          column_type_in_association(association_method)
        else
          klass.columns.find{ |kc| kc.name == column_name}.type
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
      
    end
  end
end