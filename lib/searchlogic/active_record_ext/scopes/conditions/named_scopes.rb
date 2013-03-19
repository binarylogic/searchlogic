module Searchlogic
  module ActiveRecordExt
    module Scopes
      module Conditions
        class NamedScopes < Condition

          def scope
            if applicable?
              klass.__send__(method_name, value).map{|returned_obj| returned_obj.__send__(klass_symbol)}.flatten
            end
          end

          def value
            args.first
          end

          def applicable?             
            ScopeReflection.new(method_name).named_scope?
          end

          def self.matcher
            nil
          end
        end
      end
    end
  end
end