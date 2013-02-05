module Searchlogic
  module Conditions
    class BeginsWith < Condition
      def scope
        klass.where("#{table_name}.#{column_name} like ?", "#{value}%") if applicable?
      end

      private
        def value
          args.first
        end

        def applicable? 
          !(/^(#{klass.column_names.join("|")})_begins_with$/ =~ method_name).nil? if klass
        end
    end
  end
end