module Searchlogic
  module Conditions
    class Equals < Condition
      def scope
        return nil if !applicable?
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

        def applicable? 
          !(/^(#{klass.column_names.join("|")})_equals$/ =~ method_name).nil? if klass
        end
    end
  end
end

