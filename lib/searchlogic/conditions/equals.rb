module Searchlogic
  module Conditions
    class Equals < Condition
      def scope
        return nil unless applicable?
        find_column
        if values.kind_of?(Array)
          values.map {|value| klass.where("#{table_name}.#{column_name} = ?", value)}.flatten
        else
          klass.where("#{table_name}.#{column_name} = ?", values)
        end
      end

      private
        def values
          args.first
        end
        def find_column
          @column_name = /(.*)_equals$/.match(method_name)[1]
        end
        def applicable? 
          !(/_equals$/ =~ method_name).nil? 
        end
    end
  end
end

