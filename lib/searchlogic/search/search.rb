module Searchlogic
  module Search
    class SearchProxy < BasicObject
      include MethodMissing
      include Attributes 
      include Base
      include ChainedConditions
      include Delegate
      include Ordering
      include ReaderWriter
    end
  end
end
