module Searchlogic
  module Search
    class SearchProxy < BasicObject
      include MethodMissing
      include Attributes 
      include Base
      include ChainedConditions
      include CountConditions
    end
  end
end
