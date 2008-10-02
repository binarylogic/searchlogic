module Searchgasm
  module Condition
    class NotLike < Base
      class << self
        def condition_names_for_column
          super + ["not_contain", "not_have"]
        end
      end
      
      def to_conditions(value)
        like = Like.new
        like.value = value
        conditions = like.to_conditions
        return conditions if conditions.blank?
        conditions.first.gsub!(" LIKE ", " NOT LIKE ")
        conditions
      end
    end
  end
end