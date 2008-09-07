module Searchgasm
  module Condition
    class DoesNotEqual < Base
      class << self
        def aliases_for_column(column)
          ["#{column.name}_is_not", "#{column.name}_not"]
        end
      end
      
      def ignore_blanks?
        false
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