module Searchlogic
  module Conditions
    class Null < Condition
      def scope
        klass.where("#{table_name}.#{column_name} is NULL")
      end

      private
        def value
          args.first
        end
    end
  end
end