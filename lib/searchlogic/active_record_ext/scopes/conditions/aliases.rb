module Searchlogic
  module ActiveRecordExt
    module Scopes
      module Conditions
        class Aliases < Condition
          def scope
            if Aliases.match_alias(method_name)
              case alias_used
              when "eq", "is"
                replace_and_send("equals")
              when  "not_equal_to", "is_not", "not", "ne"
                replace_and_send("does_not_equal")
              when "lt", "before"
                replace_and_send("less_than")
              when "lte", "less_than_or_equal"
                replace_and_send("less_than_or_equal_to")
              when "gt", "after"
                replace_and_send("greater_than")
              when "gte", "greater_than_or_equal"
                replace_and_send("greater_than_or_equal_to")
              when "contains", "includes"
                replace_and_send("like")
              when "does_not_include" 
                replace_and_send("not_like")
              when "bw" 
                replace_and_send("begins_with")
              when "not_begin_with"
                replace_and_send("does_not_begin_with")
              when "ew"
                replace_and_send("ends_with")
              when "not_end_with" 
                replace_and_send("does_not_end_with")
              when "nil"
                replace_and_send("null")
              when "not_nil"
                replace_and_send("not_null")
              when "present"
                replace_and_send("not_blank")
              end
            end
          end

          def self.match_alias(method)
              /(is|eq|not_equal_to|is_not|not|ne|lt|before|lte|gt|after|gte|contains|includes|does_not_include|bw|not_begin_with|ew|not_end_with|nil|not_nil|present)$/.match(method)
          end

          private

            def replace_and_send(method)
              method = method_name.to_s.gsub(alias_used, method)
              klass.send(method, value)
            end
            def alias_used
              Aliases.match_alias(method_name)[0]
            end
        end
      end
    end
  end
end
