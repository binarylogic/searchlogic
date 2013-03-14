require 'pry'
module Searchlogic
  module ActiveRecordExt
    module Scopes
      module Conditions
        class NormalizeInput < Condition
          DELIMITER = "__"
          attr_accessor :converted_method
          def scope
            if applicable?
              convert_syntax(method_name, klass)
              method = converted_method
              return nil if method.nil?

              klass.send(method, value)
            end
          end

          def self.matcher
            nil
          end
          private 

          def convert_syntax(method, for_klass)
            meth = method
            if !!(incorrect_syntax(for_klass).match(meth))
              syntax_error = meth.to_s.scan(incorrect_syntax(for_klass)).flatten.first
              associated_klass = syntax_error.gsub(/_$/, "").singularize.camelize.constantize
              converted_method = meth.to_s.gsub(syntax_error, syntax_error + "_") 
              convert_syntax(converted_method, associated_klass ) if incorrect_syntax(associated_klass) =~ converted_method
              self.converted_method = converted_method unless incorrect_syntax(associated_klass) =~ converted_method
            else
              meth
            end 
          end

          def applicable?
            /(#{(ActiveRecord::Base.connection.tables + ActiveRecord::Base.connection.tables.map(&:singularize)).join("|")})_[^_]/ =~ method_name && !(preference_to_columns?)
          end

          def incorrect_syntax(match_klass)
            /(#{matching_incorrect_syntax(match_klass)})[^_]/
          end

          def preference_to_columns?
            ##give preference to columns if method starts with col_nam_known_scope or known_scope_col_name
            /^(#{klass.column_names.join("|")})(#{ScopeReflection.all_scopes.join("|")})/ =~ method_name ||  /^(ascend_by_|descend_by_)(#{klass.column_names.join("|")})/ =~ method_name
          end

          def matching_incorrect_syntax(match_klass)
            match_klass.reflect_on_all_associations.map(&:name).map { |k| k.to_s + "_" }.join("|")
          end
        end
      end
    end
  end
end

