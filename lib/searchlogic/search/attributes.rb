module Searchlogic
  module Search
    class SearchProxy
        module AttributesReaderWriters
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