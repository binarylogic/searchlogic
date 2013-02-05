module Searchlogic
  module Conditions
    class Equals < Condition


      def process(value)
        column_name = $1        
        klass.where("#{column} = ?", value)
      end
      def applicable?(name)
      !(/^(#{column_names.join("|")})_equals$/).nil?
      end
    end
  end
end