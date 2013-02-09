module Searchlogic
  module Conditions
    class Blank < Condition
      def scope
        if applicable?
          find_column
          klass.where("#{table_name}.#{column_name} is null OR #{table_name}.#{column_name} = ? OR #{table_name}.#{column_name} = ?", false ,  "") 
        end
      end

      private
        def value
          args.first
        end

        def find_column
          @column_name = /(.*)_blank$/.match(method_name)[1]
        end
        def applicable? 
          !(/_blank$/ =~ method_name).nil? 
        end
    end
  end
end