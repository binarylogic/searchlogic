module Searchlogic
  module Conditions
    class Blank < Condition
      def scope
        klass.where("#{table_name}.#{column_name} is null OR #{table_name}.#{column_name} = ? OR #{table_name}.#{column_name} = ?", false ,  "")
      end

      private
        def value
          args.first
        end
    end
  end
end