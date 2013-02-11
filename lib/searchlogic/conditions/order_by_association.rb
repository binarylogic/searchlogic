module Searchlogic
  module Conditions
    class OrderByAssociation < Condition
      def scope
        if applicable?
          association = find_association
          method_without_association = method_name.to_s.split(association + "_").join
          klass.joins(association.pluralize.to_sym).send(method_without_association)            
        end
      end

      private
        def value
          args.first
        end

        def method_without_ordering
          split_method[2]
        end

        def ordering 
          split_method[1] 
        end

        def split_method
          /(.*_by_)(.*)/.match(method_name)
        end

        def find_association
          associations_in_method.find{|a| /^#{a}/.match(method_without_ordering.to_s)}
        end
        def associations_in_method
          klass.tables + klass.tables.map(&:singularize)
        end
        def applicable? 
          /_by_#{associations_in_method.join("|")}.*/ =~ method_name
        end
    end
  end
end