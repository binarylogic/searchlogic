module Searchlogic
  module Conditions
    class Joins < Condition
      DELIMITER = "__"
      def scope
        return nil unless applicable?
        method = method_name.to_s.split(DELIMITER)
        join_name = method.shift.to_sym
        association = klass.reflect_on_all_associations.find { |association| association.name == join_name }
        nested_scope = association.klass.send(method.join(DELIMITER), value) 
        klass.joins(join_name => nested_scope.joins_values).where(nested_scope.where_values.first).uniq
      end

      private
        def applicable?
          !(/#{DELIMITER}/.match(method_name).nil?)
        end
    end
  end
end