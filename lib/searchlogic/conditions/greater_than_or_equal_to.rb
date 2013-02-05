module Searchlogic
  module Conditions
    class GreaterThanOrEqualTo < Condition
      def scope
        klass.where("#{table_name}.#{column_name} >= ?", "#{value}") if applicable?
      end

      private
        def value
          args.first
        end

        def applicable? 
          !(/^(#{klass.column_names.join("|")})_greater_than_or_equal_to$/ =~ method_name).nil? if klass
        end
    end
  end
end