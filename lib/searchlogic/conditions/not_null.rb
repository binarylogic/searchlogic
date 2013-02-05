module Searchlogic
  module Conditions
    class NotNull < Condition
      def scope
        klass.where("#{table_name}.#{column_name} is not NULL") if applicable?
      end

      private
        def value
          args.first
        end

        def applicable? 
          !(/^(#{klass.column_names.join("|")})_not_null$/ =~ method_name).nil? if klass
        end
    end
  end
end