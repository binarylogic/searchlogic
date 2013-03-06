module Searchlogic
  module ActiveRecordExt
    module Scopes
      module Conditions
        class NamedScopeArity < Condition

          def scope
            if applicable?
            end
          end

          def self.matcher
            "named_scope_arity"
          end
        end
      end
    end
  end
end
