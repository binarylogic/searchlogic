module Searchlogic
  module Conditions
    class Equals < Condition

      def generate_scope(value)
        puts "generating scope" 
        puts value

        if current_scope = scope(method)
          klass.where("#{current_scope} = ?", value)
        end
      end

      private 
      def scope(method)
        puts "Scoping"
        match = /^(#{column_names.join("|")})_equals$/.match(method)
        match[1] if match
      end
    end
  end
end

