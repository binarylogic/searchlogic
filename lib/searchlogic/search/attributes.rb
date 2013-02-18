module Searchlogic
  module Search
    class SearchProxy < BasicObject
      module Attributes
        def conditions
          @conditions
        end
        def klass
          @klass
        end
        def method
          @method
        end
      end
    end
  end
end