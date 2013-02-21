module Searchlogic
  class Search < Base
    include Attributes
    include ChainedConditions
    include ReaderWriter
    include Ordering
    include MethodMissing
    include Delegate
  end
end
