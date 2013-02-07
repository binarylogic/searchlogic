module Searchlogic
  module Conditions
    class DoesNotBeginWith < Condition
      def scope
         klass.where("#{table_name}.#{column_name} not like ?", "#{value}%") if applicable?
      end

      private
        def value
          args.first
        end
        def applicable? 
          !(/^(#{klass.column_names.join("|")})_does_not_begin_with$/ =~ method_name).nil? 
        end
    end
  end
end