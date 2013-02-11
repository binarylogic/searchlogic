module Searchlogic
  module Conditions
    class Joins < Condition
      
      def scope
        if applicable?
          method = method_name.to_s.split("__")
          join_klass =  method.shift.to_sym 
          method = method.join("__")
          join = klass.joins(join_klass)
          join.send(method, value, join_klass)
        end
      end

      private
        def applicable?
          !(/__/.match(method_name).nil?)
        end
    end
  end
end