module Searchgasm
  module Condition
    class NotIlike < Base
      class << self
        def condition_names_for_column
          super + ["not_icontain", "not_ihave"]
        end
      end
      
      def to_conditions(value)
        like = Ilike.new(klass, options)
        like.value = value
        conditions = like.to_conditions
        return conditions if conditions.blank?
        conditions.first.gsub!(" ILIKE ", " NOT ILIKE ")
        conditions
      end
    end
  end
end