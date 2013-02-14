module Searchlogic
  module Conditions
    class Joins < Condition
      DELIMITER = "__"

      def scope
        return nil unless applicable?
        method_parts = method_name.to_s.split(DELIMITER)
        first_part = method_parts.shift.to_sym
        match_ordering ? join_name = match_ordering[2] : join_name = first_part
        new_method = match_ordering ? match_ordering[1] + method_parts.join(DELIMITER) : method_parts.join(DELIMITER)
        association = klass.reflect_on_all_associations.find { |association| association.name == join_name || association.name.to_s == join_name }
        nested_scope = association.klass.send(new_method, value)
        join_values = nested_scope.joins_values
        if match_ordering
          send_method = match_ordering[1] + method_parts.last
          klass.
            joins(join_values.any? ? {join_name => join_values.first} : join_name.to_sym).
            send(send_method)
        else
          klass.
          joins(join_values.any? ? {join_name => join_values.first} : join_name.to_sym).
          where(nested_scope.where_values.first).uniq
        end
      end

      private
        def applicable?
          !(/#{DELIMITER}/.match(method_name).nil?)
        end

        def match_ordering
          /(descend_by_|ascend_by_)(.*)/.match(method_name.to_s.split(DELIMITER).first)
        end
    end
  end
end