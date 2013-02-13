module Searchlogic
  module Conditions
    class Polymorphic < Condition
      # def scope
      #   if applicable?
      #     args.flatten!
      #     initial_scope = klass.send(new_method, args[0])
      #     args.inject(initial_scope){|scope, value| scope.send(new_method, value)}
      #   end
      # end

      # private
      #   def new_method
      #     /(.*)_all/.match(method_name)[1]
      #   end
      #   def applicable? 
      #     !(/_all/ =~ method_name).nil?
      #   end
    end
  end
end

