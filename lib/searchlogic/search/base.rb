require "pry"
module Searchlogic
  module Search
    class SearchProxy < BasicObject
      module Base
        def initialize(klass, method, conditions)
          return nil unless method == :search
          @klass = klass
          @method = method
          @conditions = conditions
        end
      end
    end
  end
end