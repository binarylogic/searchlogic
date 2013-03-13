module Searchlogic
  module ActiveRecordExt
    module Scopes
      module Conditions
        class Polymorphic < Condition
            attr_accessor :where_values, :joins_values
            def initialize(*args)
              super
              @where_values ||= []
              @joins_values ||= []
            end
          def scope
            if applicable?
              obj = association_klass.send(new_method, value)
              where_values << obj.where_values
              joins_values << obj.joins_values
              obj.map do |returned_obj| 
                returned_obj.send(klass_symbol)
              end                                
            end
          end
            def self.matcher
              nil
            end
            def association_klass
              method_parts = method_name.to_s.split("_type_")
              method_parts[0].split(polymorphic_association_name + "_").last.camelize.constantize
            end
            
            def new_method
              method_parts = method_name.to_s.split("_type_").last
            end            

          private
            def applicable? 
              polymorphic_association && method_name.to_s.include?(polymorphic_association.name.to_s)
            end

            def polymorphic_association_name
              klass.reflect_on_all_associations.map{ |a| a.name if a.options[:polymorphic]}.compact.first.to_s
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
