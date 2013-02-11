module Searchlogic
  module Conditions
    class Like < Condition

      def scope
        if applicable?
          column_name = find_column[1]
          klass.where("#{table_name}.#{column_name} like ?", "%#{value}%")  
        end

      end

      private
        def applicable? 
          !(find_column).nil? 
        end

        def find_column
          /(.*)_like$/.match(method_name)
        end
    end
  end
end