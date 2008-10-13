module Searchgasm
  module Modifiers
    class Upper < Base
      class << self
        def modifier_names
          super + ["upcase"]
        end
        
        def return_type
          :string
        end
      end
    end
  end
end