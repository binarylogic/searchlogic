module Searchlogic
  module ActiveRecordExt
    module Scopes
      module Conditions
        class Polymorphic < Condition
          def scope
            if applicable?
              scope = association_klass.send(new_method, value) #.map{|returned_obj| returned_obj.send(klass_symbol)}.flatten
              scope.inject(scope){|scope, item_in_scope| scope + item_in_scope.send(klass_symbol)}
              binding.pry
            end
          end
            def self.matcher
              nil
            end
          private
            def applicable? 
              polymorphic_association && method_name.to_s.include?(polymorphic_association.name.to_s)
            end

            def polymorphic_association_name
              klass.reflect_on_all_associations.map{ |a| a.name if a.options[:polymorphic]}.compact.first.to_s
            end

            def association_klass
              method_parts = method_name.to_s.split("_type_")
              method_parts[0].split(polymorphic_association_name + "_").last.camelize.constantize
            end
            
            def new_method
              method_parts = method_name.to_s.split("_type_").last
            end

            def polymorphic_association
              klass.reflect_on_all_associations.flatten.detect{|association| association.options[:polymorphic]}
            end

            def klass_symbol
              klass.name.downcase.pluralize.to_sym
            end
        end
      end
    end
  end
end
