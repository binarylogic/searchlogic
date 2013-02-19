module Searchlogic
  module Search
    class SearchProxy < BasicObject
      module Delegate
        def delegate(method_name, args, &block)

          if conditions.empty?
            send_delegated_method(method_name, klass, args, &block)
          else
            send_delegated_method(method_name, chained_conditions(sanitized_conditions), args, &block)            
          end
        end
        private 
          def send_delegated_method(method, klass, args, &block)
            args.empty? ? klass.send(method) : klass.send(method, args, &block)
          end

          ##Have Sanitized conditions in this class so they're only changed once
          ##the method has been delegated and the original search object never changes
          def sanitized_conditions
            implicit_equals(replace_nils)
          end
          def replace_nils
            conditions.inject({}) do |h, (key, value)|  
              if value.nil?
                new_key = (key.to_s + "_null").to_sym
                h[new_key] = true 
                h 
              else
                h[key] = value
                h 
              end
            end
          end

          def implicit_equals(nil_sanitized_conditions)
            nil_sanitized_conditions.inject({}) do |h, (key, value)|  
              if klass.column_names.detect{|kcn| kcn.to_sym == key}
                new_key = (key.to_s + "_equals").to_sym
                h[new_key] = value
                h
              else
                h[key] = value
                h
              end
            end 
          end
      end
    end
  end
end