module Searchlogic
  module Conditions
    class NotBlank < Condition
      def scope
        if applicable? && args.first != false          
          find_column
          klass.where("#{table_name}.#{column_name} not null AND #{table_name}.#{column_name} <> ? AND #{table_name}.#{column_name} <> ?", false , "") 
        elsif applicable? && args.first == false
          send_to_blank
        else
          false
        end
      end

      private
        def value
          args.first
        end
        def find_column
          @column_name = /(.*)_not_blank$/.match(method_name)[1]
        end
        def applicable? 
          !((/_not_blank$/ =~ method_name).nil?)
        end
        def send_to_blank
          klass.send(find_column + "_blank")
        end

    end
  end
end