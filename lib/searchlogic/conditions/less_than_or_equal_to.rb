module Searchlogic
  module Conditions
    class LessThanOrEqualTo < Condition
      def scope
        klass.where("#{table_name}.#{column_name} <= ?", "#{value}") if applicable?
      end

      private
        def value
          args.first
        end
        def applicable? 
          !(/^(#{klass.column_names.join("|")})_less_than_or_equal_to$/ =~ method_name).nil?
        end
    end
  end
end