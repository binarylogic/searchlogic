module Searchlogic
  module Conditions
    class NotLike < Condition
      def scope
        klass.where("#{table_name}.#{column_name} not like ?", "%#{value}%") if applicable?
      end

      private
        def value
          args.first
        end

        def applicable? 
          !(/^(#{klass.column_names.join("|")})_not_like$/ =~ method_name).nil? if klass
        end
    end
  end
end