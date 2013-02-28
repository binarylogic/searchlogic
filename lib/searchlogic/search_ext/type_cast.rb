module Searchlogic
  module SearchExt
    module TypeCast
      def typecast(method, value)
        case column_type(method)
        when :boolean
          cast_boolean(value)
        when :integer
          value.kind_of?(Array) ? cast_in_array(value, "cast_integer") : cast_integer(value)
        when :float 
          value.kind_of?(Array) ? cast_in_array(value, "cast_float") : cast_float(value)
        when :string
          value.kind_of?(Array) ? cast_in_array(value, "cast_string") : cast_string(value)
        when :date
          value.kind_of?(Array) ? cast_in_array(value, "cast_date") : cast_date(value)
        when :datetime
          value.kind_of?(Array) ? cast_in_array(value, "cast_time") : cast_time(value)
        when :ordering
          value
        when :scope
          value
        else 
          value
        end
      end
      private 
        def column_type(method)
          if ordering?(method)
            :ordering
          elsif boolean_method?(method)
            :boolean 
          elsif klass.searchlogic_scopes.include?(method)
            :scope
          elsif association_method = association_in_method(klass, method)
            
            find_column(association_method)
          else
            column = klass.columns.find{|kc| method.to_s.include?(kc.name.to_s)}
            column = column.sort_by{|c1, c2| c.name.size <=> c.name.size } if column.kind_of?(Array)
            column.type
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

        def find_column(association_method)
          association, new_method = association_method

          new_klass = association.singularize.camelize.constantize
          column = new_klass.columns.find{|kc| new_method.to_s.include?(kc.name.to_s)}
          column = column.sort_by{|c1, c2| c.name.size <=> c.name.size } if column.kind_of?(Array) 
          ass_method = association_in_method(new_klass, new_method)
          column ? column.type : find_column(ass_method)
        end

        def cast_boolean(value)
          if value == "false" || value == false || value == "0" ||  value == nil ||  value == "nil" || value == 0 || value == "null" 
            false
          else
            true
          end
        end

        def boolean_method?(method)
          !!(["null", "nil", "blank", "present"].find{|m| method.to_s.include?(m)})
        end

        def cast_integer(value)
          if value.kind_of?(String)
            value.to_i
          else
            value
          end
        end

        def cast_in_array(array, method)
          array.map { |v| self.send(method, v) }
        end

        def cast_float(value)
          if value.kind_of?(String)
            value.to_f
          else
            value
          end
        end

        def cast_date(value)
          Date.parse(value)
        end

        def cast_time(value)
          value.kind_of?(Time) ? value : Time.zone.parse(value)
        end
        def cast_string(value)
          value
        end

    end
  end
end
