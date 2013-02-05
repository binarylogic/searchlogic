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
        puts method
        /^(#{column_names.join("|")})_equals$/.match(method.to_s)[1]
      end
    end
  end
end