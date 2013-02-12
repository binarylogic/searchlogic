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
         incorrect_syntax = method_name.to_s.scan(regex).flatten.first
         method_name.to_s.gsub(incorrect_syntax, incorrect_syntax + "_")
      end
      def applicable?
        regex =~ method_name
      end
      def regex
        matching_incorrect_syntax = klass.tables.map { |k| k + "_" }.join("|")
        /(#{matching_incorrect_syntax})[^_]/
      end
    end
  end
end

