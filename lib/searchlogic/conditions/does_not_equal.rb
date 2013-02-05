module Searchlogic
  module Conditions
    class DoesNotEqual < Condition
      def scope
        klass.where("#{table_name}.#{column_name} != ?", "#{value}") if applicable?
      end

      private
        def value
          args.first
        end

        def applicable? 
          !(/^(#{klass.column_names.join("|")})_does_not_equal$/ =~ method_name).nil? if klass
        end
    end
  end
end