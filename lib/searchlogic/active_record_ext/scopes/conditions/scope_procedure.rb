module Searchlogic
  module ActiveRecordExt
    module Scopes
      module Conditions
        class ScopeProcedure < Condition

          def scope
            if applicable?
              association_klass.send(new_method, value).map{|returned_obj| returned_obj.send(klass_symbol)}.flatten
            end
          end

          def value
            args.first
          end

          def applicable?             
            klass.named_scopes.detect{ |scope| scope.to_s == method_name.to_s }
          end
        end
      end
    end
  end
end