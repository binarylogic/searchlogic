module Searchlogic
  module Search
    class SearchProxy < BasicObject
      module Base
        def initialize(klass, conditions)
          @klass = klass
          @method = method
          @conditions = conditions ||= {}
        end
      end
    end
  end
end