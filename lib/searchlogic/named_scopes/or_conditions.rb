module Searchlogic
  module NamedScopes
    # Handles dynamically creating named scopes for 'OR' conditions. Please see the README for a more
    # detailed explanation.
    module OrConditions
      class NoConditionSpecifiedError < StandardError; end
      class UnknownConditionError < StandardError; end
      
      def condition?(name) # :nodoc:
        super || or_condition?(name)
      end
      
      private
        def or_condition?(name)
          !or_conditions(name).nil?
        end
        
        def method_missing(name, *args, &block)
          if conditions = or_conditions(name)
            create_or_condition(conditions, args)
            (class << self; self; end).class_eval { alias_method name, conditions.join("_or_") } if !respond_to?(name)
            send(name, *args)
          else
            super
          end
        end
        
        def or_conditions(name)
          # First determine if we should even work on the name, we want to be as quick as possible
          # with this.
          if (parts = split_or_condition(name)).size > 1
            conditions = interpolate_or_conditions(parts)
            if conditions.any?
              conditions
            else
              nil
            end
          end
        end
        
        def split_or_condition(name)
          parts = name.to_s.split("_or_")
          new_parts = []
          parts.each do |part|
            if part =~ /^equal_to(_any|_all)?$/
              new_parts << new_parts.pop + "_or_equal_to"
            else
              new_parts << part
            end
          end
          new_parts
        end
        
        # The purpose of this method is to convert the method name parts into actual condition names.
        #
        # Example:
        #
        #   ["first_name", "last_name_like"]
        #   => ["first_name_like", "last_name_like"]
        #
        #   ["id_gt", "first_name_begins_with", "last_name", "middle_name_like"]
        #   => ["id_gt", "first_name_begins_with", "last_name_like", "middle_name_like"]
        #
        # Basically if a column is specified without a condition the next condition in the list
        # is what will be used. Once we are able to get a consistent list of conditions we can easily
        # create a scope for it.
        def interpolate_or_conditions(parts)
          conditions = []
          last_condition = nil
          
          parts.reverse.each do |part|
            if details = condition_details(part)
              # We are a searchlogic defined scope
              conditions << "#{details[:column]}_#{details[:condition]}"
              last_condition = details[:condition]
            elsif details = association_condition_details(part)
              # pending, need to find the last condition
            elsif local_condition?(part)
              # We are a custom scope
              conditions << part
            elsif column_names.include?(part)
              # we are a column, use the last condition
              if last_condition.nil?
                raise NoConditionSpecifiedError.new("The '#{part}' column doesn't know which condition to use, if you use an exact column " +
                  "name you need to specify a condition sometime after (ex: id_or_created_at_lt), where id would use the 'lt' condition.")
              end
              
              conditions << "#{part}_#{last_condition}"
            else
              raise UnknownConditionError.new("The condition '#{part}' is not a valid condition, we could not find any scopes that match this.")
            end
          end
          
          conditions.reverse
        end
        
        def create_or_condition(scopes, args)
          named_scope scopes.join("_or_"), lambda { |*args|
            merge_scopes_with_or(scopes.collect { |scope| [scope, *args] })
          }
        end
        
        def merge_scopes_with_or(scopes)
          scopes_options = scopes.collect { |scope, *args| send(scope, *args).proxy_options }
          conditions = scopes_options.reject { |o| o[:conditions].nil? }.collect { |o| sanitize_sql(o[:conditions]) }
          
          scope = scopes.inject(scoped({})) do |scope, info|
            scope_name, *args = info
            scope.send(scope_name, *args)
          end
          
          scope.scope(:find).merge(:conditions => "(" + conditions.join(") OR (") + ")")
        end
    end
  end
end