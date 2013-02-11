module Searchlogic
  module Conditions
    class OrderByAssociation < Condition
      def scope
        if applicable?
          new_method = method_name.to_s.split("#{find_association}_").join
          association = find_association.pluralize
          klass.joins(association.to_sym).send(new_method.to_sym)
        end
      end

      private
        def value
          args.first
        end

        def find_association
          associations.find{|a| method_name.to_s.include?(a)}
        end
        def associations
          klass.reflect_on_all_associations.map{ |a| a.name.to_s.singularize}
        end
        def applicable? 
          /_by_#{associations.join("|")}.*/ =~ method_name
        end
    end
  end
end