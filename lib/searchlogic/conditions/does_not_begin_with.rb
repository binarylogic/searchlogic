module Searchlogic
  module Conditions
    class DoesNotBeginWith < Condition
      def scope
         klass.where("#{table_name}.#{column_name} not like ?", "#{value}%")
      end

      private
        def value
          args.first
        end
    end
  end
end