module Searchlogic
  module Conditions
    class NotNull < Condition
      def scope
        klass.where("#{table_name}.#{column_name} is not NULL") 
      end

      private
        def value
          args.first
        end
    end
  end
end