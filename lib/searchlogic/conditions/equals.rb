module Searchlogic
  module Conditions
    class Equals < Condition


      def process(value)
        column_name = $1
        table.where("#{column_name} = ?", value)

          klass.where("#{column} = ?", value)
        else
          puts "DINT RUN"
        end
      end
      private 
      def applicable?(name)
      !(/^(#{column_names.join("|")})_equals$/).nil?
      end
    end
  end
end