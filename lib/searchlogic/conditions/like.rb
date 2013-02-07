module Searchlogic
  module Conditions
    class Like < Condition
      def scope
        klass.where("#{table_name}.#{column_name} like ?", "%#{value}%") if applicable? 
      end

      private
        def value
          args.first
        end

        def applicable? 
          !(/^(#{klass.column_names.join("|")})_like$/ =~ method_name).nil? 
        end
    end
  end
end