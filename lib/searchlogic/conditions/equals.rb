module Searchlogic
  module Conditions
    class Equals < Condition

      def scope
        if values.kind_of?(Array)
          returned_objects = values.map {|value| klass.where("#{table_name}.#{column_name} = ?", value)}.flatten if applicable?
        else
          klass.where("#{table_name}.#{column_name} = ?", values) if applicable?
        end
      end

      private
        def values
          args.first
        end
        def applicable? 
          !(/^(#{klass.column_names.join("|")})_equals$/ =~ method_name).nil? if klass
        end
    end
  end
end

