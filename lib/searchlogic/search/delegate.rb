module Searchlogic
  module Search
    class SearchProxy < BasicObject
      module Delegate
        def delegate(method_name, args, &block)

          if conditions.empty?
            send_delegated_method(method_name, klass, args, &block)
          else
            send_delegated_method(method_name, chained_conditions, args, &block)            
          end
        end
        private 
          def send_delegated_method(method, klass, args, &block)
            args.empty? ? klass.send(method) : klass.send(method, args, &block)
          end
      end
    end
  end
end