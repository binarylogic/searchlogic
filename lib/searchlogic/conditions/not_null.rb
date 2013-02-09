module Searchlogic
  module Conditions
    class NotNull < Condition
      def scope
        if applicable?
          find_column
          klass.where("#{table_name}.#{column_name} is not NULL")
        end
      end

      private
        def value
          args.first
        end
        def find_column
          @column_name = /(.*)_not_null$/.match(method_name)[1]
        end
        def applicable? 
          !(/_not_null$/ =~ method_name).nil?
        end
    end
  end
end