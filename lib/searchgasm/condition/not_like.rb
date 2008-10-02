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
        like.to_conditions.gsub(" LIKE ", " NOT LIKE ")
      end
    end
  end
end