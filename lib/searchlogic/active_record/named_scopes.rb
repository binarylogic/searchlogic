module Searchlogic
  module ActiveRecord
    # Adds methods that give extra information about a classes named scopes.
    module NamedScopes
      # Retrieves the options passed when creating the respective named scope. Ex:
      #
      #   named_scope :whatever, :conditions => {:column => value}
      #
      # This method will return:
      #
      #   :conditions => {:column => value}
      #
      # ActiveRecord hides this internally in a Proc, so we have to try and pull it out with this
      # method.
      def named_scope_options(name)
        key = scopes.key?(name.to_sym) ? name.to_sym : primary_condition_name(name)
        
        if key
          eval("options", scopes[key].binding)
        else
          nil
        end
      end
      
      # The arity for a named scope's proc is important, because we use the arity
      # to determine if the condition should be ignored when calling the search method.
      # If the condition is false and the arity is 0, then we skip it all together. Ex:
      #
      #   User.named_scope :age_is_4, :conditions => {:age => 4}
      #   User.search(:age_is_4 => false) == User.all
      #   User.search(:age_is_4 => true) == User.all(:conditions => {:age => 4})
      #
      # We also use it when trying to "copy" the underlying named scope for association
      # conditions. This way our aliased scope accepts the same number of parameters for
      # the underlying scope.
      def named_scope_arity(name)
        options = named_scope_options(name)
        options.respond_to?(:arity) ? options.arity : nil
      end
      
      # A convenience method for creating inner join sql to that your inner joins
      # are consistent with how Active Record creates them. Basically a tool for
      # you to use when writing your own named scopes. This way you know for sure
      # that duplicate joins will be removed when chaining scopes together that
      # use the same join.
      #
      # Also, don't worry about breaking up the joins or retriving multiple joins.
      # ActiveRecord will remove dupilicate joins and Searchlogic assists ActiveRecord in
      # breaking up your joins so that they are unique.
      def inner_joins(association_name)
        ::ActiveRecord::Associations::ClassMethods::InnerJoinDependency.new(self, association_name, nil).join_associations.collect { |assoc| assoc.association_join }
      end
      
      # See inner_joins, except this creates LEFT OUTER joins.
      def left_outer_joins(association_name)
        ::ActiveRecord::Associations::ClassMethods::JoinDependency.new(self, association_name, nil).join_associations.collect { |assoc| assoc.association_join }
      end
    end
  end
end