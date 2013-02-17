module Searchlogic
  module Search
    class SearchProxy < BasicObject
      include MethodMissing
      include AttributesReaderWriters 
      include Base
      include ChainedConditions
    end
  end
end
