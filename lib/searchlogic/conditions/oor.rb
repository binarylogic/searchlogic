module Searchlogic
  module Conditions
    class Oor < Condition
      def scope
        if applicable?
          methods = method_name.to_s.split("_or_")
          last_condition = find_condition(methods.last)
          methods.map { |m| klass.send(add_condition(m, last_condition), value) }.flatten
        end
      end

      private
        def find_condition(last_method)
          klass.joined_condition_klasses.split("|").find{ |jck| last_method.include?(jck)}
        end

        def add_condition(method, condition)
          find_condition(method) ? method : method + "_" + condition
        end

        def applicable? 
          !(/_or_/ =~ method_name).nil?
        end
    end
  end
end

