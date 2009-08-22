module Searchlogic
  module NamedScopes
    # Handles dynamically creating named scopes for ordering by columns. Example:
    #
    #   User.ascend_by_id
    #   User.descend_by_username
    #
    # See the README for a more detailed explanation.
    module Ordering
      def condition?(name) # :nodoc:
        super || ordering_condition?(name)
      end
      
      private
        def ordering_condition?(name) # :nodoc:
          !ordering_condition_details(name).nil?
        end
        
        def method_missing(name, *args, &block)
          if name == :order
            named_scope name, lambda { |scope_name|
              return {} if !condition?(scope_name)
              send(scope_name).proxy_options
            }
            send(name, *args)
          elsif details = ordering_condition_details(name)
            create_ordering_conditions(details[:column])
            send(name, *args)
          else
            super
          end
        end
        
        def ordering_condition_details(name)
          if name.to_s =~ /^(ascend|descend)_by_(#{column_names.join("|")})$/
            {:order_as => $1, :column => $2}
          elsif name.to_s =~ /^order$/
            {}
          end
        end
        
        def create_ordering_conditions(column)
          named_scope("ascend_by_#{column}".to_sym, {:order => "#{table_name}.#{column} ASC"})
          named_scope("descend_by_#{column}".to_sym, {:order => "#{table_name}.#{column} DESC"})
        end
    end
  end
end