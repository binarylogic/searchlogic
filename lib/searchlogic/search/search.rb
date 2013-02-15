module Searchlogic
  module Search
    class SearchProxy < BasicObject
      include MethodMissing
      include AttributesReaderWriters 
      include Base
    end
  end
end
