module Searchlogic
  module NamedScopes
    # Handles dynamically creating named scopes for associations.
    module AssociationConditions
      def condition?(name) # :nodoc:
        super || association_condition?(name) || association_alias_condition?(name)
      end
      
      def primary_condition_name(name) # :nodoc:
        if result = super
          result
        elsif association_condition?(name)
          name.to_sym
        elsif details = association_alias_condition_details(name)
          "#{details[:association]}_#{details[:column]}_#{primary_condition(details[:condition])}".to_sym
        else
          nil
        end
      end
      
      # Is the name of the method a valid name for an association condition?
      def association_condition?(name)
        !association_condition_details(name).nil?
      end
      
      # Is the ane of the method a valie name for an association alias condition?
      # An alias being "gt" for "greater_than", etc.
      def association_alias_condition?(name)
        !association_alias_condition_details(name).nil?
      end
      
      # A convenience method for creating inner join sql to that your inner joins
      # are consistent with how Active Record creates them.
      def inner_joins(association_name)
        ActiveRecord::Associations::ClassMethods::InnerJoinDependency.new(self, association_name, nil).join_associations.collect { |assoc| assoc.association_join }
      end
      
      private
        def method_missing(name, *args, &block)
          if details = association_condition_details(name)
            create_association_condition(details[:association], details[:column], details[:condition], args)
            send(name, *args)
          elsif details = association_alias_condition_details(name)
            create_association_alias_condition(details[:association], details[:column], details[:condition], args)
            send(name, *args)
          else
            super
          end
        end
        
        def association_condition_details(name)
          associations = reflect_on_all_associations.collect { |assoc| assoc.name }
          if !local_condition?(name) && name.to_s =~ /^(#{associations.join("|")})_(\w+)_(#{Conditions::PRIMARY_CONDITIONS.join("|")})$/
            {:association => $1, :column => $2, :condition => $3}
          end
        end
        
        def create_association_condition(association_name, column, condition, args)
          named_scope("#{association_name}_#{column}_#{condition}", association_condition_options(association_name, "#{column}_#{condition}", args))
        end
        
        def association_alias_condition_details(name)
          associations = reflect_on_all_associations.collect { |assoc| assoc.name }
          if !local_condition?(name) && name.to_s =~ /^(#{associations.join("|")})_(\w+)_(#{Conditions::ALIAS_CONDITIONS.join("|")})$/
            {:association => $1, :column => $2, :condition => $3}
          end
        end
        
        def create_association_alias_condition(association, column, condition, args)
          primary_condition = primary_condition(condition)
          alias_name = "#{association}_#{column}_#{condition}"
          primary_name = "#{association}_#{column}_#{primary_condition}"
          send(primary_name, *args) # go back to method_missing and make sure we create the method
          (class << self; self; end).class_eval { alias_method alias_name, primary_name }
        end
        
        def association_condition_options(association_name, association_condition, args)
          association = reflect_on_association(association_name.to_sym)
          scope = association.klass.send(association_condition, *args)
          scope_options = association.klass.named_scope_options(association_condition)
          arity = association.klass.named_scope_arity(association_condition)
          
          if !arity || arity == 0
            # The underlying condition doesn't require any parameters, so let's just create a simple
            # named scope that is based on a hash.
            options = scope.proxy_options
            options[:joins] = options[:joins].blank? ? association.name : {association.name => options[:joins]}
            options
          else
            # The underlying condition requires parameters, let's match the parameters it requires
            # and pass those onto the named scope. We can't use proxy_options because that returns the
            # result after a value has been passed.
            proc_args = []
            if arity > 0
              arity.times { |i| proc_args << "arg#{i}"}
            else
              positive_arity = arity * -1
              positive_arity.times do |i|
                if i == (positive_arity - 1)
                  proc_args << "*arg#{i}"
                else
                  proc_args << "arg#{i}"
                end
              end
            end
            eval <<-"end_eval"
              searchlogic_lambda(:#{scope_options.searchlogic_arg_type}) { |#{proc_args.join(",")}|
                options = association.klass.named_scope_options(association_condition).call(#{proc_args.join(",")})
                options[:joins] = options[:joins].blank? ? association.name : {association.name => options[:joins]}
                options
              }
            end_eval
          end
        end
    end
  end
end