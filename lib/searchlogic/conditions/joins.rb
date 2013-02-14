module Searchlogic
  module Conditions
    class Joins < Condition
      DELIMITER = "__"
      def initialize(*args)
        super
      end
      def scope
        return nil unless applicable?
        method_parts = method_name.to_s.split(DELIMITER)
        join_name = method_parts.shift.to_sym
        association = klass.reflect_on_all_associations.find { |association| association.name == join_name }
        nested_scope = association.klass.send(method_parts.join(DELIMITER), value)
        join_values = nested_scope.joins_values
        klass.
          joins(join_values.any? ? {join_name => join_values.first} : join_name).
            where(nested_scope.where_values.first).uniq
      end

      private
        def applicable?
          !(/#{DELIMITER}/.match(method_name).nil?)
        end
    end
  end
end