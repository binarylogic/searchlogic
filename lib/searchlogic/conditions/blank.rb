module Searchlogic
  module Conditions
    class Blank < Condition
      def scope
        klass.where("#{table_name}.#{column_name} is null OR #{table_name}.#{column_name} = ? OR #{table_name}.#{column_name} = ?", false ,  "") if applicable?
      end

      private
        def value
          args.first
        end

        def applicable? 
          !(/^(#{klass.column_names.join("|")})_blank$/ =~ method_name).nil? if klass
        end
    end
  end
end