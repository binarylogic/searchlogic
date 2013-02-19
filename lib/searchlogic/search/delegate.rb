require 'pry'
module Searchlogic
  module Search
    class SearchProxy < BasicObject
      module Delegate
        def delegate(method_name, args, &block)
          args = nil if args.empty?
          if conditions.empty?
            klass.send(method_name, args, &block)
          else
            chained_conditions(sanitized_conditions).send(method_name, args, &block)            
          end
        end
        private 
          ##Sanitized conditions in this class so they're only changed once
          ##the method has been delegated. This allows for the original search object to stay the same
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