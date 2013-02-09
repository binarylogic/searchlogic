module Searchlogic
  module Conditions
    class BeginsWith < Condition
      def scope
        if applicable?
          find_column
          klass.where("#{table_name}.#{column_name} like ?", "#{value}%") 
        end
      end

      private
        def value
          args.first
        end
        def find_column
          @column_name = /(.*)_begins_with$/.match(method_name)[1]
        end
        def applicable? 
          !(/_begins_with$/ =~ method_name).nil?
        end
    end
  end
end