module Searchlogic
  module ActiveRecordExt
    module Scopes
      module Conditions
        class Polymorphic < Condition
          attr_reader :associated_klass_name
          def initialize(*args)
            super
            @associated_klass_name = association_klass.name.underscore.pluralize rescue nil
          end
          def scope

            if applicable?
              klass.where("#{polymorphic_association.name}_type = '#{association_klass}'").
                    joins("LEFT OUTER JOIN #{associated_klass_name} ON #{associated_klass_name}.id = #{klass.name.underscore.pluralize}.#{polymorphic_association.name}_id ").
                    where(where_values)
            end


          end
            def self.matcher
              nil
            end
            def association_klass
              method_parts = method_name.to_s.split("_type_")
              method_parts[0].split(polymorphic_association_name + "_").last.camelize.constantize
            end
            
            def method_on_association
              method_parts = method_name.to_s.split("_type_").last
            end            

          private
            def applicable? 
              polymorphic_association && method_name.to_s.include?(polymorphic_association.name.to_s)
            end

            def where_values
              association_klass.send(method_on_association, value).where_values.last
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