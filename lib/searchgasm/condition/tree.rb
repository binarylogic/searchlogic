module Searchgasm
  module Condition
    class Tree < Base # :nodoc:
      class << self
        def condition_names_for_column
          []
        end
        
        def condition_names_for_model(model)
          [condition_type_name]
        end
      end
    end
  end
end