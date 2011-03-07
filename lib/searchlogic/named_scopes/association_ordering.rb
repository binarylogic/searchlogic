module Searchlogic
  module NamedScopes
    # Handles dynamically creating order named scopes for associations:
    #
    #   User.has_many :orders
    #   Order.has_many :line_items
    #   LineItem
    #
    #   User.ascend_by_orders_line_items_id
    #
    # See the README for a more detailed explanation.
    module AssociationOrdering
      def condition?(name) # :nodoc:
        super || association_ordering_condition?(name)
      end

      private
        def association_ordering_condition?(name)
          !association_ordering_condition_details(name).nil?
        end

        def create_condition(name)
          if details = association_ordering_condition_details(name)
            create_association_ordering_condition(details[:association], details[:order_as], details[:condition])
          else
            super
          end
        end

        def association_ordering_condition_details(name)
          associations = reflect_on_all_associations
          association_names = associations.collect { |assoc| assoc.name }
          if name.to_s =~ /^(ascend|descend)_by_(#{association_names.join("|")})_(\w+)$/
            {:order_as => $1, :association => associations.find { |a| a.name == $2.to_sym }, :condition => $3}
          end
        end

        def create_association_ordering_condition(association, order_as, condition)
         cond = condition
         poly_class = nil
         if condition =~ /^(\w+)_type_(\w+)$/
           poly_type = $1
           cond = $2
           poly_class = poly_type.camelcase.constantize if poly_type
         end
         named_scope("#{order_as}_by_#{association.name}_#{condition}", association_condition_options(association, "#{order_as}_by_#{cond}", poly_class))
        end
    end
  end
end
