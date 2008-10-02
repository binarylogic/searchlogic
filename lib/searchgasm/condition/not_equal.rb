module Searchgasm
  module Condition
    class NotEqual < Base
      self.handle_array_value = true
      self.ignore_meaningless_value = false
      
      class << self
        def condition_names_for_column
          super + ["does_not_equal", "not_equal", "is_not", "not"]
        end
      end
      
      def to_conditions(value)
        # Delegate to equals and then change
        condition = Equals.new(klass, column)
        condition.value = value
        
        sql = condition.sanitize
        sql.gsub!(/ IS /, " IS NOT ")
        sql.gsub!(/ BETWEEN /, " NOT BETWEEN ")
        sql.gsub!(/ IN /, " NOT IN ")
        sql.gsub!(/=/, "!=")
        sql
      end
    end
  end
end