module Searchlogic
  module NamedScopes
    module Associations
      def condition?(name)
        super || association_condition?(name) || association_alias_condition?(name)
      end
      
      def primary_condition_name(name)
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
      
      def association_condition?(name)
        !association_condition_details(name).nil?
      end
      
      def association_alias_condition?(name)
        !association_alias_condition_details(name).nil?
      end
      
      private
        def method_missing(name, *args, &block)
          if details = association_condition_details(name)
            create_association_condition(details[:association], details[:column], details[:condition], args)
            send(name, *args)
          elsif details = association_alias_condition_details(name)
            create_association_alias_condition(details[:association], details[:column], details[:condition], args)
            send(name, *args)
          elsif details = association_ordering_condition_details(name)
            create_association_ordering_condition(details[:association], details[:order_as], details[:column], args)
            send(name, *args)
          else
            super
          end
        end
        
        def association_condition_details(name)
          associations = reflect_on_all_associations.collect { |assoc| assoc.name }
          if name.to_s =~ /^(#{associations.join("|")})_(\w+)_(#{Conditions::PRIMARY_CONDITIONS.join("|")})$/
            {:association => $1, :column => $2, :condition => $3}
          end
        end
        
        def create_association_condition(association_name, column, condition, args)
          named_scope("#{association_name}_#{column}_#{condition}", association_condition_options(association_name, "#{column}_#{condition}", args))
        end
        
        def association_alias_condition_details(name)
          associations = reflect_on_all_associations.collect { |assoc| assoc.name }
          if name.to_s =~ /^(#{associations.join("|")})_(\w+)_(#{Conditions::ALIAS_CONDITIONS.join("|")})$/
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
        
        def association_ordering_condition_details(name)
          associations = reflect_on_all_associations.collect { |assoc| assoc.name }
          if name.to_s =~ /^(ascend|descend)_by_(#{associations.join("|")})_(\w+)$/
            {:order_as => $1, :association => $2, :column => $3}
          end
        end
        
        def create_association_ordering_condition(association_name, order_as, column, args)
          named_scope("#{order_as}_by_#{association_name}_#{column}", association_condition_options(association_name, "#{order_as}_by_#{column}", args))
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
            add_left_outer_joins(options, association)
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
                add_left_outer_joins(options, association)
                options
              }
            end_eval
          end
        end
        
        # In a named scope you have 2 options for adding joins: :include and :joins.
        #
        # :include will execute multiple queries for each association and instantiate objects for each association.
        # This is not what we want when we are searching. The only other option left is :joins. We can pass the
        # name of the association directly, but AR creates an INNER JOIN. If we are ordering by an association's
        # attribute, and that association is optional, the records without an association will be omitted. Again,
        # not what we want.
        #
        # So the only option left is to use :joins with manually written SQL. We can still have AR generate this SQL
        # for us by leveraging it's join dependency classes. Instead of using the InnerJoinDependency we use the regular
        # JoinDependency which creates a LEFT OUTER JOIN, which is what we want.
        #
        # The code below was extracted out of AR's add_joins! method and then modified.
        def add_left_outer_joins(options, association)
          join = ActiveRecord::Associations::ClassMethods::JoinDependency.new(self, association.name, nil).join_associations.collect { |assoc| assoc.association_join }.join.strip
          options[:joins] ||= []
          options[:joins].unshift(join)
        end
    end
  end
end