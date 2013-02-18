module Searchlogic
  module Search
    class SearchProxy < BasicObject
      module Base
        def initialize(klass, conditions)
          @klass = klass
          @method = method
          @conditions = ignore_nils(conditions)
        end

        def ignore_nils(conditions)
          return {} unless conditions
          conditions.select{|k, v| !v.nil? } 
        end
      end
    end
  end
end