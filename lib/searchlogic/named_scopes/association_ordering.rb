module Searchlogic
  module NamedScopes
    # Handles dynamically creating named scopes for associations.
    module AssociationOrdering
      private
        def method_missing(name, *args, &block)
          if details = association_ordering_condition_details(name)
            create_association_ordering_condition(details[:association], details[:order_as], details[:column], args)
            send(name, *args)
          else
            super
          end
        end
        
        def association_ordering_condition_details(name)
          associations = reflect_on_all_associations.collect { |assoc| assoc.name }
          if !local_condition?(name) && name.to_s =~ /^(ascend|descend)_by_(#{associations.join("|")})_(\w+)$/
            {:order_as => $1, :association => $2, :column => $3}
          end
        end
        
        def create_association_ordering_condition(association_name, order_as, column, args)
          named_scope("#{order_as}_by_#{association_name}_#{column}", association_condition_options(association_name, "#{order_as}_by_#{column}", args))
        end
    end
  end
end