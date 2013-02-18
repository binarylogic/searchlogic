module Searchlogic
  module Search
    class SearchProxy < BasicObject
      include MethodMissing
      include Attributes 
      include Base
      include ChainedConditions
    end
  end
end
