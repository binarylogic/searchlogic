module Searchlogic
  module NamedScopes
    # Handles dynamically creating named scopes for associations.
    module AssociationOrdering
      def condition?(name) # :nodoc:
        super || association_ordering_condition?(name)
      end
      
      def primary_condition_name(name) # :nodoc
        if result = super
          result
        elsif association_ordering_condition?(name)
          name.to_sym
        else
          nil
        end
      end
      
      private
        def association_ordering_condition?(name)
          !association_ordering_condition_details(name).nil?
        end
        
        def method_missing(name, *args, &block)
          if details = association_ordering_condition_details(name)
            create_association_ordering_condition(details[:association], details[:order_as], details[:condition], args)
            send(name, *args)
          else
            super
          end
        end
        
        def association_ordering_condition_details(name)
          associations = reflect_on_all_associations.collect { |assoc| assoc.name }
          if name.to_s =~ /^(ascend|descend)_by_(#{associations.join("|")})_(\w+)$/
            {:order_as => $1, :association => $2, :condition => $3}
          end
        end
        
        def create_association_ordering_condition(association, order_as, condition, args)
          named_scope("#{order_as}_by_#{association}_#{condition}", association_condition_options(association, "#{order_as}_by_#{condition}", args))
        end
    end
  end
end