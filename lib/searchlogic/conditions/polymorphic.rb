module Searchlogic
  module Conditions
    class Polymorphic < Condition
      def scope
        if applicable?
          association_klass.send(new_method, value).map{|returned_obj| returned_obj.send(klass.name.downcase.pluralize.to_sym)}.flatten
        end
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
    end
  end
end

# Audit.belongs_to :auditable, :polymorphic => true
# User.has_many :audits, :as => :auditable

# Audit.auditable_user_type_username_equals("ben") 
# User.audits_name_equals("IRS") => Audit.where()
#   => Audit.user_equals("ben")