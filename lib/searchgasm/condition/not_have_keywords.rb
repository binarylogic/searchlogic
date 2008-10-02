module Searchgasm
  module Condition
    class NotHaveKeywords < Base
      class << self
        def condition_names_for_column
          super + ["not_have_keywords", "not_keywords", "not_have_kw", "not_kw", "not_have_kwwords", "not_kwwords"]
        end
      end
      
      def to_conditions(value)
        keywords = Keywords.new
        keywords.value = value
        keywords.to_conditions.gsub(" LIKE ", " NOT LIKE ")
      end
    end
  end
end