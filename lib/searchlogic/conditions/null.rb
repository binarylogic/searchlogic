module Searchlogic
  module Conditions
    class Null < Condition
      def scope
        if applicable?
          find_column
          klass.where("#{table_name}.#{column_name} is NULL")
        end
      end

      private
        def value
          args.first
        end

        def find_column

          @column_name = (/(.*)_null/).match(method_name)[1]
        end
        def applicable? 
          !(/_null$/ =~ method_name).nil?
        end
    end
  end
end