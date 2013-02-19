module Searchlogic
  module Search
    class SearchProxy < BasicObject
      module ReaderWriter
        private 
        def read_or_write_condition(scope_name, args)
          args.empty? ? read_condition(scope_name) : write_condition(scope_name, args.first)
        end
        def write_condition(key, value)
          conditions[key] = value
          self
        end
        def read_condition(key)
          conditions[key]
        end
      end
    end
  end
end