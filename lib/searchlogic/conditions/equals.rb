module Searchlogic
  module Conditions
    class Equals < Condition

      def scope
        klass.where("#{table_name}.#{column_name} = ?", value) if applicable?
      end

      private
        def value
          args.first
        end

        def applicable? 
          !(/^(#{klass.column_names.join("|")})_equals$/ =~ method_name).nil? if klass
        end
    end
  end
end

