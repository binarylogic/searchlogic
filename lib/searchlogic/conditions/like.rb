module Searchlogic
  module Conditions
    class Like < Condition

      def scope
        if applicable?
          find_column
          klass.where("#{table_name}.#{column_name} like ?", "%#{value}%"  )  

        end

      end

      private
        def applicable? 
          !(/_like$/ =~ method_name).nil? 
        end

        def find_column
          @column_name =/(.*)_like$/.match(method_name)[1]
        end

        def calc_or_conditions
          find_columns.map { |cn| "OR #{table_name}.#{cn} like #{value}" }[1..-1].join(" ").gsub!(value, value.split("").unshift("'%").push("%'").join) 
        end
    end
  end
end