module Searchlogic
  module Conditions
    class GreaterThan < Condition
      def scope
        if applicable?
          find_column
          klass.where("#{table_name}.#{column_name} > ?", "#{value}") if applicable?
        end
      end

      private
        def value
          args.first
        end
        def find_column
          @column_name = /(.*)_greater_than/.match(method_name)[1]
        end
        def applicable? 
          !(/_greater_than/ =~ method_name).nil?
        end
    end
  end
end