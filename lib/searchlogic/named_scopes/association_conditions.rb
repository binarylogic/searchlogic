module Searchlogic
  module NamedScopes
    # Handles dynamically creating named scopes for associations.
    module AssociationConditions
      def condition?(name) # :nodoc:
        super || association_condition?(name)
      end
      
      def primary_condition_name(name) # :nodoc:
        if result = super
          result
        elsif association_condition?(name)
          name.to_sym
        else
          nil
        end
      end
      
      private
        def association_condition?(name)
          !association_condition_details(name).nil?
        end
        
        def method_missing(name, *args, &block)
          if !local_condition?(name) && details = association_condition_details(name)
            create_association_condition(details[:association], details[:condition], args)
            send(name, *args)
          else
            super
          end
        end
        
        def association_condition_details(name)
          assocs = reflect_on_all_associations.reject { |assoc| assoc.options[:polymorphic] }
          return nil if assocs.empty?
          
          if name.to_s =~ /^(#{assocs.collect(&:name).join("|")})_(\w+)$/
            association_name = $1
            condition = $2
            association = reflect_on_association(association_name.to_sym)
            klass = association.klass
            if klass.condition?(condition)
              {:association => $1, :condition => $2}
            else
              nil
            end
          end
        end
        
        def create_association_condition(association, condition, args)
          named_scope("#{association}_#{condition}", association_condition_options(association, condition, args))
        end
        
        def association_condition_options(association_name, association_condition, args)
          association = reflect_on_association(association_name.to_sym)
          scope = association.klass.send(association_condition, *args)
          scope_options = association.klass.named_scope_options(association_condition)
          arity = association.klass.named_scope_arity(association_condition)
          
          if !arity || arity == 0
            # The underlying condition doesn't require any parameters, so let's just create a simple
            # named scope that is based on a hash.
            options = scope.scope(:find)
            prepare_named_scope_options(options, association)
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
            
            arg_type = (scope_options.respond_to?(:searchlogic_arg_type) && scope_options.searchlogic_arg_type) || :string
            
            eval <<-"end_eval"
              searchlogic_lambda(:#{arg_type}) { |#{proc_args.join(",")}|
                scope = association.klass.send(association_condition, #{proc_args.join(",")})
                options = scope ? scope.scope(:find) : {}
                prepare_named_scope_options(options, association)
                options
              }
            end_eval
          end
        end
        
        def prepare_named_scope_options(options, association)
          options.delete(:readonly)
          
          if options[:joins].is_a?(String) || array_of_strings?(options[:joins])
            options[:joins] = [inner_joins(association.name), options[:joins]].flatten
          else
            options[:joins] = options[:joins].blank? ? association.name : {association.name => options[:joins]}
          end
        end
    end
  end
end