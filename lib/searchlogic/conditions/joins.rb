module Searchlogic
  module Conditions
    class Joins < Condition
      DELIMITER = "__"
      def scope
        if applicable?
          method = method_name.to_s.split(DELIMITER)
          join_name = method.shift.to_sym
          association = klass.reflect_on_all_associations.find { |association| association.name == join_name }
          nested_scope = association.klass.send(method.join(DELIMITER), value) 
          if nested_scope.joins_values.empty?
            klass.joins(join_name).where(nested_scope.where_values.first).uniq
          else
            klass.joins(join_name => nested_scope.joins_values).where(nested_scope.where_values.first).uniq
          end
        end
      end

      private
        def applicable?
          !(/#{DELIMITER}/.match(method_name).nil?)
        end
    end
  end
end