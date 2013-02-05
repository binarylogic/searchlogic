module Searchlogic
  module Conditions
    class Equals < Condition

      def scope
        returned_objects = values.map {|value| klass.where("#{table_name}.#{column_name} = ?", value)}.flatten if applicable?
      end

      private
        def values
          [args.first].flatten
        end

        def applicable? 
          !(/^(#{klass.column_names.join("|")})_equals$/ =~ method_name).nil? if klass
        end
    end
  end
end

