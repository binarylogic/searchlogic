module Searchlogic
  module NamedScopes
    # Handles dynamically creating named scopes for columns. It allows you to do things like:
    #
    #   User.first_name_like("ben")
    #   User.id_lt(10)
    #
    # Notice the constants in this class, they define which conditions Searchlogic provides.
    #
    # See the README for a more detailed explanation.
    module Conditions
      COMPARISON_CONDITIONS = {
        :equals => [:is, :eq],
        :does_not_equal => [:not_equal_to, :is_not, :not, :ne],
        :less_than => [:lt, :before],
        :less_than_or_equal_to => [:lte],
        :greater_than => [:gt, :after],
        :greater_than_or_equal_to => [:gte],
      }
      
      WILDCARD_CONDITIONS = {
        :like => [:contains, :includes],
        :not_like => [],
        :begins_with => [:bw],
        :not_begin_with => [:does_not_begin_with],
        :ends_with => [:ew],
        :not_end_with => [:does_not_end_with]
      }
      
      BOOLEAN_CONDITIONS = {
        :null => [:nil],
        :not_null => [:not_nil],
        :empty => [],
        :blank => [],
        :not_blank => [:present]
      }
      
      CONDITIONS = {}
      
      # Add any / all variations to every comparison and wildcard condition
      COMPARISON_CONDITIONS.merge(WILDCARD_CONDITIONS).each do |condition, aliases|
        CONDITIONS[condition] = aliases
        CONDITIONS["#{condition}_any".to_sym] = aliases.collect { |a| "#{a}_any".to_sym }
        CONDITIONS["#{condition}_all".to_sym] = aliases.collect { |a| "#{a}_all".to_sym }
      end
      
      BOOLEAN_CONDITIONS.each { |condition, aliases| CONDITIONS[condition] = aliases }
      
      PRIMARY_CONDITIONS = CONDITIONS.keys
      ALIAS_CONDITIONS = CONDITIONS.values.flatten
      
      # Is the name of the method a valid condition that can be dynamically created?
      def condition?(name)
        local_condition?(name)
      end
      
      private
        def local_condition?(name)
          return false if name.blank?
          scope_names = scopes.keys.reject { |k| k == :scoped }
          scope_names.include?(name.to_sym) || !condition_details(name).nil?
        end
        
        def method_missing(name, *args, &block)
          if details = condition_details(name)
            create_condition(details[:column], details[:condition], args)
            send(name, *args)
          else
            super
          end
        end
        
        def condition_details(name)
          if name.to_s =~ /^(#{column_names.join("|")})_(#{(PRIMARY_CONDITIONS + ALIAS_CONDITIONS).join("|")})$/
            {:column => $1, :condition => $2}
          end
        end
        
        def create_condition(column, condition, args)
          if PRIMARY_CONDITIONS.include?(condition.to_sym)
            create_primary_condition(column, condition)
          elsif ALIAS_CONDITIONS.include?(condition.to_sym)
            create_alias_condition(column, condition, args)
          end
        end
        
        def create_primary_condition(column, condition)
          column_type = columns_hash[column.to_s].type
          match_keyword = ::ActiveRecord::Base.connection.adapter_name == "PostgreSQL" ? "ILIKE" : "LIKE"
          
          scope_options = case condition.to_s
          when /^equals/
            scope_options(condition, column_type, lambda { |a| attribute_condition("#{table_name}.#{column}", a) })
          when /^does_not_equal/
            scope_options(condition, column_type, "#{table_name}.#{column} != ?")
          when /^less_than_or_equal_to/
            scope_options(condition, column_type, "#{table_name}.#{column} <= ?")
          when /^less_than/
            scope_options(condition, column_type, "#{table_name}.#{column} < ?")
          when /^greater_than_or_equal_to/
            scope_options(condition, column_type, "#{table_name}.#{column} >= ?")
          when /^greater_than/
            scope_options(condition, column_type, "#{table_name}.#{column} > ?")
          when /^like/
            scope_options(condition, column_type, "#{table_name}.#{column} #{match_keyword} ?", :like)
          when /^not_like/
            scope_options(condition, column_type, "#{table_name}.#{column} NOT #{match_keyword} ?", :like)
          when /^begins_with/
            scope_options(condition, column_type, "#{table_name}.#{column} #{match_keyword} ?", :begins_with)
          when /^not_begin_with/
            scope_options(condition, column_type, "#{table_name}.#{column} NOT #{match_keyword} ?", :begins_with)
          when /^ends_with/
            scope_options(condition, column_type, "#{table_name}.#{column} #{match_keyword} ?", :ends_with)
          when /^not_end_with/
            scope_options(condition, column_type, "#{table_name}.#{column} NOT #{match_keyword} ?", :ends_with)
          when "null"
            {:conditions => "#{table_name}.#{column} IS NULL"}
          when "not_null"
            {:conditions => "#{table_name}.#{column} IS NOT NULL"}
          when "empty"
            {:conditions => "#{table_name}.#{column} = ''"}
          when "blank"
            {:conditions => "#{table_name}.#{column} = '' OR #{table_name}.#{column} IS NULL"}
          when "not_blank"
            {:conditions => "#{table_name}.#{column} != '' AND #{table_name}.#{column} IS NOT NULL"}
          end
          
          named_scope("#{column}_#{condition}".to_sym, scope_options)
        end
        
        # This method helps cut down on defining scope options for conditions that allow *_any or *_all conditions.
        # Kepp in mind that the lambdas get cached in a method, so you want to keep the contents of the lambdas as
        # fast as possible, which is why I didn't do the case statement inside of the lambda.
        def scope_options(condition, column_type, sql, value_modifier = nil)
          case condition.to_s
          when /_(any|all)$/
            searchlogic_lambda(column_type) { |*values|
              return {} if values.empty?
              values.flatten!
              values.collect! { |value| value_with_modifier(value, value_modifier) }
              
              join = $1 == "any" ? " OR " : " AND "
              scope_sql = values.collect { |value| sql.is_a?(Proc) ? sql.call(value) : sql }.join(join)
              
              {:conditions => [scope_sql, *expand_range_bind_variables(values)]}
            }
          else
            searchlogic_lambda(column_type) { |*values|
              values.collect! { |value| value_with_modifier(value, value_modifier) }
              
              scope_sql = sql.is_a?(Proc) ? sql.call(*values) : sql
              
              {:conditions => [scope_sql, *expand_range_bind_variables(values)]}
            }
          end
        end
        
        def value_with_modifier(value, modifier)
          case modifier
          when :like
            "%#{value}%"
          when :begins_with
            "#{value}%"
          when :ends_with
            "%#{value}"
          else
            value
          end
        end
        
        def create_alias_condition(column, condition, args)
          primary_condition = primary_condition(condition)
          alias_name = "#{column}_#{condition}"
          primary_name = "#{column}_#{primary_condition}"
          send(primary_name, *args) # go back to method_missing and make sure we create the method
          (class << self; self; end).class_eval { alias_method alias_name, primary_name }
        end
        
        # Returns the primary condition for the given alias. Ex:
        #
        #   primary_condition(:gt) => :greater_than
        def primary_condition(alias_condition)
          CONDITIONS.find { |k, v| k == alias_condition.to_sym || v.include?(alias_condition.to_sym) }.first
        end

        # Returns the primary name for any condition on a column. You can pass it
        # a primary condition, alias condition, etc, and it will return the proper
        # primary condition name. This helps simply logic throughout Searchlogic. Ex:
        #
        #   primary_condition_name(:id_gt) => :id_greater_than
        #   primary_condition_name(:id_greater_than) => :id_greater_than
        def primary_condition_name(name)
          if details = condition_details(name)
            if PRIMARY_CONDITIONS.include?(name.to_sym)
              name
            else
              "#{details[:column]}_#{primary_condition(details[:condition])}".to_sym
            end
          else
            nil
          end
        end
    end
  end
end
