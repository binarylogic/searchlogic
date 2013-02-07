module Searchlogic
  module Conditions
    class GreaterThan < Condition
      def scope
        klass.where("#{table_name}.#{column_name} > ?", "#{value}") if applicable?
      end

      private
        def value
          args.first
        end
        def applicable? 
          !(/^(#{klass.column_names.join("|")})_greater_than$/ =~ method_name).nil?
        end
    end
  end
end