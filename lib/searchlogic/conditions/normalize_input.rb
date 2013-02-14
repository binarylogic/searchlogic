module Searchlogic
  module Conditions
    class NormalizeInput < Condition
      def scope
        if applicable?
          method = convert_syntax
          klass.send(method, value)
        end
      end
      private 

      def convert_syntax
        if incorrect_syntax =~ method_name
          syntax_error = method_name.to_s.scan(incorrect_syntax).flatten.first
          method_name.to_s.gsub(syntax_error, syntax_error + "_")    
        else
          syntax_error = method_name.to_s.scan(incorrect_syntax_in_ordering).flatten.last
          method_name.to_s.gsub(syntax_error, syntax_error + "_")
        end
      end

      def applicable?
        (incorrect_syntax =~ method_name) || (incorrect_syntax_in_ordering =~ method_name)
      end
      def incorrect_syntax
        /(#{matching_incorrect_syntax})[^_]/
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

