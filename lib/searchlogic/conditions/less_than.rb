module Searchlogic
  module Conditions
    class LessThan < Condition
      def scope
        klass.where("#{table_name}.#{column_name} < ?", "#{value}") if applicable?
      end

      private
        def value
          args.first
        end
        def applicable? 
          !(/^(#{klass.column_names.join("|")})_less_than$/ =~ method_name).nil? 
        end
    end
  end
end