module Searchlogic
  module Conditions
    class Any < Condition
      def scope
        if applicable?
          args.flatten.map do |value|
            klass.send(new_method, value)
          end.flatten
        end
      end

      private
        def new_method
          /(.*)_any/.match(method_name)[1]
        end
        def applicable? 
          !(/_any/ =~ method_name).nil?
        end
    end
  end
end

