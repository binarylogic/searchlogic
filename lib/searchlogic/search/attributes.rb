module Searchlogic
  class Search < Base
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