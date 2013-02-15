module Searchlogic
  module Search
    class SearchProxy < BasicObject
      module MethodMissing
        private
        def method_missing(method, *args, &block)
          ::Object.send(:binding).pry
          @attributes ||= {}
          scope_name = method.to_s.gsub(/=$/, '')
          if klass.respond_to?(scope_name)
            @attributes[method.to_s.gsub(/=$/, '')] = args.first
          elsif @attributes.key?(method)
            @attributes[method]
          else
            chained_scopes.send(method, *args, &block)
          end
        end
      end
    end
  end
end