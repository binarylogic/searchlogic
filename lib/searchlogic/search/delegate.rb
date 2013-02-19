module Searchlogic
  module Search
    class SearchProxy < BasicObject
      module Delegate
        def delegate(method_name, args, &block)

          if conditions.empty?
            send_delegated_method(method_name, klass, args, &block)
          else
            nil_sanitized_conditions = replace_nils
            send_delegated_method(method_name, chained_conditions(nil_sanitized_conditions), args, &block)            
          end
        end
        private 
          def send_delegated_method(method, klass, args, &block)
            args.empty? ? klass.send(method) : klass.send(method, args, &block)
          end
          def replace_nils
            conditions.inject({}) do |h, (k, v)|  
              if v.nil?
                new_key = (k.to_s + "_null").to_sym
                h[new_key] = true 
                h 
              else
                h[k] = v
                h 
              end
            end
          end
      end
    end
  end
end