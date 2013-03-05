module Searchlogic
  module SearchExt
    module Base
      def initialize(klass, conditions)
        @klass = klass
        self.conditions = conditions
      end

      def clone
        Searchlogic::Search.new(klass, conditions)
      end
      
      def klass
        @klass
      end 
    end
  end
end
