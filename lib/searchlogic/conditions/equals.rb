module Searchlogic
  module Conditions
    class Equals < Condition
      def scope
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
    end
  end
end

