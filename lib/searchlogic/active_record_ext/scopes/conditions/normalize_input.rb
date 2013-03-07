require 'pry'
module Searchlogic
  module ActiveRecordExt
    module Scopes
      module Conditions
        class NormalizeInput < Condition
          DELIMITER = "__"
          def scope
            if applicable?
              method = convert_syntax 
              klass.send(method, value)
            end
          end

          def self.matcher
            nil
          end
          private 

          def convert_syntax
            methods = method_name.to_s.split(DELIMITER)
            methods.map do |method| 
              if !!(incorrect_syntax.match(method))
                method.to_s.gsub(incorrect_syntax.match(method)[1], incorrect_syntax.match(method)[1] + "_")    
              elsif incorrect_syntax_in_ordering.match(method)
                syntax_error = method.to_s.scan(incorrect_syntax_in_ordering).flatten.last
                method.to_s.gsub(syntax_error, syntax_error + "_")
              else
                method
              end
            end.join(DELIMITER)
          end

          def applicable?
            (incorrect_syntax =~ method_name || incorrect_syntax_in_ordering =~ method_name)  && !(preference_to_columns?)
          end

          def incorrect_syntax
            /(#{matching_incorrect_syntax})[^_]/
          end

          def preference_to_columns?
            ##give preference to columns if method starts with col_nam_known_scope or known_scope_col_name
            /^(#{klass.column_names.join("|")})(#{ScopeReflection.all_scopes(klass).join("|")})/ =~ method_name ||  /^(ascend_by_|descend_by_)(#{klass.column_names.join("|")})/ =~ method_name
          end

          def matching_incorrect_syntax
            klass.tables.map { |k| k + "_" }.join("|")
          end

          def incorrect_syntax_in_ordering
            singular_tables = klass.tables.map { |k| k.singularize + "_" }.join("|")
            #match an ordering that includes a singular table followed by column,
            #assume the table is meant as an association and pluralize
            /(ascend_by_|descend_by_)(#{singular_tables})[^_]/
          end
        end
      end
    end
  end
end

