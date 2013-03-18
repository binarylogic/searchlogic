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
              return nil if converted_method.nil?
              klass.__send__(converted_method, value)
            end
          end

          def self.matcher
            nil
          end
          private 

          def convert_syntax(method, for_klass)
            m = method.to_s.split(DELIMITER)
            meth = method
            if !!(incorrect_syntax(for_klass).match(meth)) && !(preference_to_columns?(m.first.singularize.camelize.constantize, m.last) rescue nil)
              syntax_error = meth.to_s.scan(incorrect_syntax(for_klass)).flatten.first
              associated_klass = syntax_error.gsub(/_$/, "").singularize.camelize.constantize
              converted_method = meth.to_s.gsub(syntax_error, syntax_error + "_") 
              if incorrect_syntax(associated_klass) =~ converted_method && !(preference_to_columns?(associated_klass, converted_method.split(DELIMITER).last))
                convert_syntax(converted_method, associated_klass)
              elsif preference_to_columns?(associated_klass, converted_method.split(DELIMITER).last)
                self.converted_method = converted_method
              else
                self.converted_method = converted_method unless incorrect_syntax(associated_klass) =~ converted_method
              end
            else
              meth
            end 
          end

          def applicable?
            /(#{(ActiveRecord::Base.connection.tables + ActiveRecord::Base.connection.tables.map(&:singularize)).join("|")})_[^_]/ =~ method_name && !(preference_to_columns?(klass, method_name))
          end

          def incorrect_syntax(match_klass)
            /(#{matching_incorrect_syntax(match_klass)})[^_]/
          end

          def preference_to_columns?(for_klass, method)
            ##give preference to columns if method starts with col_nam_known_scope or known_scope_col_name
            /^(#{for_klass.column_names.join("|")})(#{ScopeReflection.all_scopes.join("|")})/ =~ method ||  /^(ascend_by_|descend_by_)(#{for_klass.column_names.join("|")})/ =~ method_name
          end

          def matching_incorrect_syntax(match_klass)
            match_klass.reflect_on_all_associations.map(&:name).map { |k| k.to_s + "_" }.join("|")
          end
        end
      end
    end
  end
end

